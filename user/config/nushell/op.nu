export def sum [
  --start (-s): any
] {
  if $start == null {
    $in | reduce { |it, acc| $acc + $it }
  } else {
    $in | reduce -f $start { |it, acc| $acc + $it }
  }
}

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
