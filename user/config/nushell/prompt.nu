module prompt_utils {
  export def color [color: string] {
    $"(ansi $color)($in)(ansi reset)"
  }

  export def git_display [] {
    if not (git branch --show-current | complete | get stderr | is-empty) { return "" }

    const display_symbols = {
      "?": "?",
      "A": "+",
      "M": "!",
      "R": ">",
      "D": "×",
    }

    let ahead_behind = git rev-list --left-right --count @{u}...HEAD
    | split row "\t"
    | each { |n| into int }
    | do {
      let ahead = if $in.1 == 0 { "" } else { $"⇡($in.1)" }
      let behind = if $in.0 == 0 { "" } else { $"⇣($in.0)" }
      $"($ahead)($behind)" | str trim
    }

    let count = git status --porcelain=1
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
}

def left_prompt [] {
  use prompt_utils *
  let user = $env.USER | color red

  let pwd = $env.PWD
  | str replace -r $"^($env.HOME)" "~"
  | path split
  | if ($in | length) > 4 { $in | last 3 | prepend "..." } else { $in }
  | path join
  | color yellow

  let memory = sys mem
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

  let git = git_display

  $"($user) ($pwd) ($memory)"
  | if $git == "" { $"($in)\n" } else { $"($in) ($git)\n" }
  | color blue
}

def right_prompt [] {
  use prompt_utils *
  let duration = {
    seconds: (($env.CMD_DURATION_MS | into int) // 1000)
    ms: (($env.CMD_DURATION_MS | into int) mod 1000)
  }
  | $"($in.seconds)s($in.ms)ms"
  | color $env.config.color_config.hints 

  let datetime = date now | format date "%d/%m/%Y %H:%M:%S" | color purple

  $"($duration) ($datetime)"
}

$env.PROMPT_COMMAND = { left_prompt }
$env.PROMPT_COMMAND_RIGHT = { right_prompt }
