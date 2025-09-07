export def sum [
  --start (-s): any
] {
  if $start == null {
    $in | reduce { |it, acc| $acc + $it }
  } else {
    $in | reduce -f $start { |it, acc| $acc + $it }
  }
}
