export def read-env [] {
  let $env_file = if $in == null {
    pwd | path join '.env'
  } else {
    $in
  }

  open $env_file
  | lines
  | where {|line| $line != "" and not ($line | str starts-with "#") }
  | parse '{key}={value}'
  | update value {|row|
    $row.value
    | split row "#"
    | first
    | str trim
    | str trim -c '"'
    | str trim -c "'"
  }
  | transpose -r -d
}

export def popup [...files: path] {
  let files = $files | each {|file| glob $file } | flatten;

  let args = if ($files | length) > 1 {
    ["-A" ...$files]
  } else {
    $files
  }

  ^dragon-drop -x ...$args
}

export def start-zellij [session?: string] {
  if 'ZELLIJ' in ($env | columns) { return }
  ^zellij

  if (
    'ZELLIJ_AUTO_EXIT' in ($env | columns) and
    $env.ZELLIJ_AUTO_EXIT == 'true'
  ) {
    exit
  }
}
