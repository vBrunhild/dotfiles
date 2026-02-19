export def sum [
  --start (-s): any
] {
  if $start == null {
    $in | reduce { |it, acc| $acc + $it }
  } else {
    $in | reduce -f $start { |it, acc| $acc + $it }
  }
}

export def read-dot-env [
  --file (-f): path
] {
  let $env_file = if $file == null {
    pwd | path join '.env'
  } else {
    $file
  }

  open $env_file
  | lines
  | parse '{key}={value}'
  | transpose -r -d
}
