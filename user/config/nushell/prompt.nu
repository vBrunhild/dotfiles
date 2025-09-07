module prompt_utils {
  export def color [color: string]: string -> string {
    $"(ansi $color)($in)(ansi reset)"
  }

  def git_display []: nothing -> string {
    if not (git branch --show-current | complete | get stderr | is-empty) { return "" }

    const display_symbols: record = {
      "?": "?",
      "A": "+",
      "M": "!",
      "R": ">",
      "D": "×",
    }

    let ahead_behind: string = git rev-list --left-right --count @{u}...HEAD
    | split row "\t"
    | each { |n| into int }
    | do {
      let ahead = if $in.1 == 0 { "" } else { $"⇡($in.1)" }
      let behind = if $in.0 == 0 { "" } else { $"⇣($in.0)" }
      $"($ahead)($behind)" | str trim
    }

    let count: string = git status --porcelain=1
    | lines
    | group-by { |line| str replace -r `^\s?\w?([?\w]).*` "$1" }
    | sort
    | transpose status count
    | update count { |c| length }
    | each { |line| $"($line.count)($display_symbols | get $line.status)" }
    | str join

    git branch --show-current
    | if ($ahead_behind == "") { $in } else { $in + $ahead_behind }
    | if ($count == "") { $in } else { $in + $"\(($count)\)" }
    | color blue
  }

  export def left_prompt []: nothing -> string {
    let user: string = $env.USER | color red

    let pwd: string = $env.PWD
    | str replace -r $"^($env.HOME)" "~"
    | path split
    | if ($in | length) > 4 { $in | last 3 | prepend "..." } else { $in }
    | path join
    | color yellow

    let memory: string = sys mem
    | select used total
    | items { |k, v| {$k: ($v | into string | parse "{size} {unit}" | into record)} }
    | into record
    | do {
      let used = if $in.used.unit == $in.total.unit {
        $in.used.size 
      } else { 
        $"($in.used.size)($in.used.unit)"
      }
      $"($used)/($in.total.size)($in.total.unit)"
    }
    | color green

    let git: string = git_display

    $"($user) ($pwd) ($memory)"
    | if $git == "" { $in } else { $"($in) ($git)" }
    | color blue
  }

  export def right_prompt []: nothing -> string {
    let duration: string = {
      seconds: (($env.CMD_DURATION_MS | into int) // 1000)
      ms: (($env.CMD_DURATION_MS | into int) mod 1000)
    }
    | $"($in.seconds)s($in.ms)ms"
    | color $env.config.color_config.hints 

    let datetime: string = date now | format date "%d/%m/%Y %H:%M:%S" | color purple

    $"($duration) ($datetime)"
  }
}

use prompt_utils
$env.PROMPT_COMMAND = { prompt_utils left_prompt }
$env.PROMPT_COMMAND_RIGHT = { prompt_utils right_prompt }
$env.PROMPT_INDICATOR = { "\n:" | prompt_utils color cyan }
$env.PROMPT_INDICATOR_VI_NORMAL = { "\n> " | prompt_utils color cyan }
$env.PROMPT_INDICATOR_VI_INSERT = { "\n: " | prompt_utils color cyan }
$env.PROMPT_MULTILINE_INDICATOR = { ": " | prompt_utils color cyan }
$env.TRANSIENT_PROMPT_INDICATOR = { "\n" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = { "\n" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = { "\n" }
