#!/usr/bin/env bash
set -e -u -o pipefail

# Configuration - override via environment variables
TUICR_PANE_DIRECTION="${TUICR_PANE_DIRECTION:-right}"  # right, down, floating or stacked
ZELLIJ_BIN="${ZELLIJ_BIN:-zellij}"

# Backward-compat: map old tmux-style position to zellij direction
case "${TUICR_PANE_POSITION:-}" in
  top|bottom) TUICR_PANE_DIRECTION="down" ;;
  left|right) TUICR_PANE_DIRECTION="right" ;;
  stacked) TUICR_PANE_DIRECTION="stacked" ;;
esac

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[tuicr]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[tuicr]${NC} $*"
}

log_error() {
  echo -e "${RED}[tuicr]${NC} $*"
}

# Splits "$@" on the `[directory] [-- tuicr-args...]` convention. Sets
# TUICR_TARGET_DIR and the TUICR_PASSTHROUGH_ARGS array instead of returning
# them, since a function's positional parameters are its own and can't shift
# the caller's.
tuicr_parse_args() {
  TUICR_TARGET_DIR="."
  if [[ "${1:-}" != "--" && -n "${1:-}" ]]; then
    TUICR_TARGET_DIR="$1"
    shift
  fi
  if [[ "${1:-}" == "--" ]]; then
    shift
  fi
  TUICR_PASSTHROUGH_ARGS=("$@")
}

# Prints each argument bash-%q-quoted with a leading space, e.g.
# `tuicr_quote_args -w` prints " -w", so the caller can append the result
# straight onto a command string: cmd="tuicr$(tuicr_quote_args "${args[@]}")"
tuicr_quote_args() {
  local arg quoted
  for arg in "$@"; do
    printf -v quoted ' %q' "$arg"
    printf '%s' "$quoted"
  done
}

# True if the installed tuicr accepts --stdout, which exports the review
# straight to a file instead of prompting the human to save & copy on exit.
tuicr_stdout_supported() {
  tuicr --help 2>&1 | grep -q -- '--stdout'
}

# Prints the review exported via --stdout, or points the caller at the
# clipboard when --stdout capture wasn't used. Cleans up output_file either
# way.
tuicr_report_stdout_output() {
  local use_stdout="$1"
  local output_file="$2"

  if [[ "$use_stdout" == true ]] && [[ -f "$output_file" ]]; then
    if [[ -s "$output_file" ]]; then
      echo ""
      echo "=== TUICR INSTRUCTIONS ==="
      cat "$output_file"
      echo "=== END TUICR INSTRUCTIONS ==="
    else
      log_info "No instructions exported from tuicr"
      log_info "If you exported to clipboard, paste the instructions here"
    fi
    rm -f "$output_file"
  else
    log_info "If you exported instructions, they are in your clipboard - paste them here"
  fi
}

usage() {
  cat << EOF
Usage: $(basename "$0") [directory] [-- tuicr-args...]

Launch tuicr in a zellij pane to review changes.

Arguments:
  directory    Git or jj repository directory to review (default: current directory)
  tuicr-args   Extra arguments passed through to tuicr (e.g. -w, -r <revset>)

Environment variables:
  TUICR_PANE_DIRECTION  right, down, floating or stacked (default: right)
  ZELLIJ_BIN            Path to zellij executable

Examples:
  $(basename "$0")                            # Review changes in current directory
  $(basename "$0") ~/project                  # Review changes in ~/project
  $(basename "$0") . -- -w                    # Review uncommitted working-tree changes
  TUICR_PANE_DIRECTION=down $(basename "$0")  # Split below instead of to the right
EOF
}

check_zellij() {
  if [[ -z "${ZELLIJ:-}" || -z "${ZELLIJ_SESSION_NAME:-}" ]]; then
    return 1
  fi
  if ! command -v "$ZELLIJ_BIN" &> /dev/null; then
    log_error "zellij command not found: $ZELLIJ_BIN"
    return 1
  fi
  return 0
}

check_deps() {
  local dep
  for dep in tuicr jq; do
    if ! command -v "$dep" &> /dev/null; then
      log_error "$dep not found. Install it first."
      return 1
    fi
  done
  return 0
}

check_repo() {
  local dir="$1"
  if git -C "$dir" rev-parse --git-dir &> /dev/null; then
    return 0
  fi
  if command -v jj &> /dev/null \
    && jj --repository "$dir" --ignore-working-copy root &> /dev/null; then
    return 0
  fi
  log_error "Not a git or jj repository: $dir"
  return 1
}

check_tuicr_running() {
  # Scoped to the repository being opened, since a tuicr reviewing some other
  # checkout is no reason to refuse this one.
  local target="$1"
  local pid cwd
  for pid in $(pgrep -x tuicr 2>/dev/null); do
    cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null) || continue
    if [[ "$cwd" == "$target" || "$cwd" == "$target"/* ]]; then
      return 0
    fi
  done
  return 1
}

list_terminal_panes() {
  "$ZELLIJ_BIN" action list-panes --json 2>/dev/null \
    | jq -c '[.[] | select(.is_plugin | not)]'
}

pane_exists() {
  local panes="$1" id="$2"
  jq -e --argjson id "$id" 'any(.[]; .id == $id)' <<< "$panes" > /dev/null
}

# Picks how the pane can actually be opened from the caller's position.
#
# zellij 0.45 silently drops tiled splits (--direction) while floating panes
# are visible in the tab, and can't stack next to a floating caller: `zellij
# run` still prints a pane id and exits 0, but the pane is never laid out. Its
# process keeps running on a pane nobody can see or close, which hangs the
# wrapper and leaves the server in a state that has crashed it on a later
# focus change. Open a floating pane instead in those cases.
resolve_direction() {
  local direction="$1"
  [[ "$direction" == "floating" ]] && { echo floating; return; }

  local caller="${ZELLIJ_PANE_ID:-}"
  [[ -n "$caller" ]] || { echo "$direction"; return; }

  local panes caller_info tab_id caller_floating
  panes=$(list_terminal_panes) || { echo "$direction"; return; }
  caller_info=$(jq -c --argjson id "$caller" 'first(.[] | select(.id == $id)) // empty' <<< "$panes")
  [[ -n "$caller_info" ]] || { echo "$direction"; return; }

  tab_id=$(jq -r '.tab_id' <<< "$caller_info")
  caller_floating=$(jq -r '.is_floating' <<< "$caller_info")

  if [[ "$caller_floating" == "true" ]] \
    || "$ZELLIJ_BIN" action are-floating-panes-visible --tab-id "$tab_id" &> /dev/null; then
    echo floating
  else
    echo "$direction"
  fi
}

launch_tuicr_pane() {
  local target_dir="$1"
  shift
  local tuicr_args=("$@")

  case "$TUICR_PANE_DIRECTION" in
    down|right|floating|stacked) ;;
    *)
      log_warn "Unknown TUICR_PANE_DIRECTION '$TUICR_PANE_DIRECTION', defaulting to 'right'"
      TUICR_PANE_DIRECTION="right"
      ;;
  esac

  local workdir
  workdir=$(mktemp -d "${TMPDIR:-/tmp}/tuicr-zellij.XXXXXX")
  # Only the scratch files go: if the wrapper is killed (e.g. an agent's
  # command timeout), tuicr stays open so the human can finish reviewing.
  # Expanded now: $workdir is local and gone by the time the EXIT trap runs.
  # shellcheck disable=SC2064
  trap "rm -rf $(printf '%q' "$workdir")" EXIT

  local pid_file="$workdir/pid"
  local output_file=""
  local use_stdout=false
  local tuicr_cmd
  tuicr_cmd="$(command -v tuicr)$(tuicr_quote_args "${tuicr_args[@]+"${tuicr_args[@]}"}")"

  if tuicr_stdout_supported; then
    output_file="$workdir/output"
    tuicr_cmd="$tuicr_cmd --stdout > $(printf '%q' "$output_file")"
    use_stdout=true
    log_info "Using --stdout mode (output will be captured)"
  else
    log_warn "tuicr --stdout not supported, output will be copied to clipboard"
  fi

  local direction
  direction=$(resolve_direction "$TUICR_PANE_DIRECTION")
  if [[ "$direction" != "$TUICR_PANE_DIRECTION" ]]; then
    log_info "Floating panes are visible here; opening a floating pane instead of '$TUICR_PANE_DIRECTION'"
  fi

  log_info "Launching tuicr in a $direction pane"
  log_info "Directory: $target_dir"

  local zellij_args=(--close-on-exit --name tuicr --cwd "$target_dir")
  # Without --near-current-pane zellij opens beside whatever is FOCUSED, which
  # is the tab the human is looking at rather than the pane this wrapper runs
  # in. It needs ZELLIJ_PANE_ID to know which pane that is.
  [[ -n "${ZELLIJ_PANE_ID:-}" ]] && zellij_args+=(--near-current-pane)

  case "$direction" in
    floating) zellij_args+=(--floating --width 90% --height 90% -x 5% -y 5%) ;;
    stacked) zellij_args+=(--stacked) ;;
    *) zellij_args+=(--direction "$direction") ;;
  esac

  # exec so the recorded pid is tuicr itself, which is what the wait loop and
  # the phantom-pane cleanup below act on. bash, not sh: $tuicr_cmd carries
  # printf %q quoting, which can emit $'...' forms dash does not understand.
  local pane_ref pane_id
  pane_ref=$("$ZELLIJ_BIN" run "${zellij_args[@]}" \
    -- bash -c "echo \$\$ > $(printf '%q' "$pid_file"); exec $tuicr_cmd")
  pane_id="${pane_ref#terminal_}"

  if [[ ! "$pane_id" =~ ^[0-9]+$ ]]; then
    log_error "zellij did not report a pane id (got: '$pane_ref')"
    return 1
  fi

  local tuicr_pid="" i
  for i in {1..50}; do
    [[ -s "$pid_file" ]] && tuicr_pid=$(< "$pid_file") && break
    sleep 0.1
  done

  if ! pane_exists "$(list_terminal_panes)" "$pane_id"; then
    # The phantom case resolve_direction tries to avoid. close-pane does not
    # stop its process, so kill tuicr directly.
    [[ -n "$tuicr_pid" ]] && kill "$tuicr_pid" 2>/dev/null || true
    "$ZELLIJ_BIN" action close-pane --pane-id "$pane_ref" &> /dev/null || true
    log_error "zellij accepted the pane but never displayed it."
    log_error "Retry with TUICR_PANE_DIRECTION=floating, or hide floating panes first."
    return 1
  fi

  if [[ -z "$tuicr_pid" ]]; then
    log_error "tuicr did not start in pane $pane_ref"
    return 1
  fi

  log_info "tuicr is running in pane $pane_ref"
  log_info "Waiting for tuicr to exit..."

  # Closing the pane SIGHUPs tuicr, so the process going away covers both a
  # normal quit and the human closing the pane by hand.
  while kill -0 "$tuicr_pid" 2>/dev/null; do
    sleep 1
  done

  log_info "tuicr finished"

  tuicr_report_stdout_output "$use_stdout" "$output_file"
}

main() {
  # Handle help
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if ! check_deps; then
    exit 1
  fi

  # Determine target directory, then split off any pass-through tuicr args
  tuicr_parse_args "$@"
  local target_dir="$TUICR_TARGET_DIR"
  target_dir=$(cd "$target_dir" && pwd)  # Get absolute path

  # Verify it's a git or jj repo
  if ! check_repo "$target_dir"; then
    exit 1
  fi

  # Check if we're in zellij
  if ! check_zellij; then
    log_error "Not running inside zellij!"
    echo ""
    echo "To use tuicr with your coding agent, run that agent inside zellij."
    echo ""
    echo "1. Exit the current agent session."
    echo ""
    echo "2. Restart the agent inside zellij (e.g. 'zellij' then run the agent)."
    echo ""
    echo "3. Then run /tuicr again."
    exit 1
  fi

  # Check if tuicr is already running
  if check_tuicr_running "$target_dir"; then
    log_warn "tuicr is already running"
    log_info "Switch to its pane with Alt-arrow keys (default zellij binding)"
    exit 0
  fi

  launch_tuicr_pane "$target_dir" "${TUICR_PASSTHROUGH_ARGS[@]+"${TUICR_PASSTHROUGH_ARGS[@]}"}"
}

main "$@"
