---
name: commit-planning
description: "Scan a repository for uncommitted changes, classify them as finished or unfinished, and produce a commits.toml plan. Use when the user says 'plan commits', 'commit plan', 'what should I commit', 'prepare commits', 'stage changes', or asks to organize uncommitted work."
---

## Safety Rules

1. **Read-only workflow.** The only file you may create or modify is `commits.toml` in the repository root.
2. **Never commit.** Do not run `git commit`, `git add`, `jj commit`, `jj new`, or any command that creates, amends, or modifies commits.
3. **Never modify source files.** No formatting fixes, no missing semicolons, no "quick cleanups." Report what you see, nothing more.

## Step 1 — Gather the Full Change Set

Start with `sem diff` to get an entity-level view of all uncommitted changes, then supplement with line-level tools for precision.

**1a. Entity-level overview (primary):**

```sh
sem diff --format json           # structured entity-level diff of working tree
sem diff --staged --format json  # staged changes (git repos only)
```

This immediately tells you which functions, classes, and methods were added, modified, deleted, or renamed — and whether modifications are structural or cosmetic. This is your primary input for grouping logical changes in Step 2.

**1b. Line-level detail (supplement):**

Use `git diff` / `jj diff` to get exact line ranges for the commits.toml output, and to catch changes `sem` doesn't parse (config files, Dockerfiles, lockfiles, prose, etc.):

```sh
# Detect VCS in use
if [ -d .jj ]; then
  jj diff --stat
  jj diff
elif [ -d .git ]; then
  git status --short
  git diff
  git diff --cached
fi
```

For large diffs, inspect targeted files:

```sh
git diff -- <path>            # or jj diff -- <path>
```

**1c. Dependency and impact context (as needed):**

When a change touches a shared function or interface and you need to understand whether related edits belong together:

```sh
sem impact <entity> --deps      # what does this entity depend on?
sem impact <entity> --dependents # what depends on this entity?
sem context <entity> --json     # entity + call graph
rg -n '<symbol>' <path>        # find usages in files sem doesn't parse
```

Use `eza --tree --git-ignore` if you need project structure for context.

## Step 2 — Identify Logical Changes

Using the `sem diff` output from Step 1, group changed entities into **logical changes**: the smallest set of edits that together form one complete, self-contained, working modification to the codebase.

**Grouping strategy — start from entities, not files:**

1. Each entity from `sem diff` (added/modified/deleted function, class, method) is a candidate seed for a logical change.
2. Use `sem impact <entity> --deps` and `--dependents` to find related changed entities. If entity A was added and entity B was modified to call A, they belong together.
3. Pull in non-code changes that serve the same intent: if a new function requires a new dependency, the lockfile/config change is part of the same logical change.
A logical change:
- Has a single clear intent (one feature, one fix, one refactor, one chore).
- Includes everything needed to keep the project buildable and functional — if the change adds a function that requires a new dependency, the dependency addition is part of the same logical change.
- May span multiple files (a function + its tests + its import = one change).
- Should not include unrelated edits even if they touch the same file.
When grouping, use the conventional commit type as a guide to intent, not as a file-category sorter. The type answers "why does this commit exist?" not "what kind of file changed." A `feat` naturally includes its deps, tests, docs, and config. Use `build`, `ci`, `docs`, `style`, `test`, etc. as primary type only when that *is* the entire point of the change.

If `sem diff` reports a `modified` entity with both structural and cosmetic changes, check the verbose diff (`sem diff -v`) to determine whether they serve the same intent or should be split.

If a single hunk contains interleaved unrelated changes (e.g., a bug fix mixed with a formatting pass), note this — it will affect the line ranges you report and may require the user to stage partial hunks.

## Step 3 — Classify: Finished vs. Unfinished

For each logical change, determine whether it is **finished** or **unfinished**.

A change is **finished** when:
- It is complete — no TODO/FIXME/HACK markers related to it, no half-written logic, no placeholder values.
- It is self-contained — does not depend on other uncommitted unfinished work to compile or run.
- It leaves the project in a working state if it were the only change applied.

A change is **unfinished** when any of those conditions fail. Common signals:
- Partial implementations (function signature exists but body is stubbed).
- Syntax errors or incomplete expressions in the changed lines.
- New dead code that nothing calls yet and is clearly in progress.
- Explicit markers: TODO, FIXME, HACK, XXX, UNFINISHED, WIP in the changed lines.

When in doubt, classify as unfinished. False negatives are harmless; false positives create broken commits.

## Step 4 — Write commits.toml

Create (or overwrite) `commits.toml` in the repository root. The format is TOML so it remains human-readable but machine-parseable.

Structure:

```toml
[[finished]]
desc = "Short description of the logical change"
msg = '''
<type>(<optional scope>): <description>

<optional body>
'''
files = [
  { name = "src/auth.py", start = 10, end = 35 },
  { name = "requirements.txt", start = 12, end = 12 },
]

[[finished]]
desc = "Another logical change"
msg = '''
fix(api): handle timeout on token refresh
'''
files = [
  { name = "src/api/client.py", start = 44, end = 60 },
  { name = "tests/test_client.py", start = 1, end = 28 },
]

[[unfinished]]
desc = "Refactor API routing"
file = { name = "src/api/routes.py", start = 30, end = 47 }

[[unfinished]]
desc = "Bump base image version"
file = { name = "Dockerfile", start = 1, end = 1 }
```

Formatting rules:
- Each finished logical change is a `[[finished]]` entry.
- `desc` is a short human-readable summary of the change.
- `msg` contains the full conventional commit message, formatted per the conventional-commits skill. Use triple-quoted strings (`'''`) so multi-line bodies with blank lines are valid TOML.
- `files` is an array of inline tables. Each entry has `name` (path relative to repo root), `start` (first changed line), and `end` (last changed line) as integers. If multiple disjoint hunks in the same file belong to the same logical change, list the file multiple times with each range.
- Each unfinished logical change is an `[[unfinished]]` entry with `desc` and a single `file` inline table. If an unfinished change spans multiple files, use one `[[unfinished]]` entry per file with the same `desc`.
- Order finished entries so that dependencies come before dependents when there is a sequencing constraint; otherwise use any sensible order (e.g., fixes before features, smaller before larger).
- All finished entries must come before any unfinished entries.
- If there are no unfinished changes, omit `[[unfinished]]` entries entirely.

## Step 5 — Present the Plan

After writing commits.toml, give the user a brief summary:
- Any observations worth flagging: interleaved changes that need partial staging, sequencing constraints between commits, or changes that were borderline to classify.

Do not prompt the user to commit. They will decide what to do with the plan.
