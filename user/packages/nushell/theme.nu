let colors = {
  purple:   '#c678dd'
  blue:     '#61afef'
  gray:     '#abb2bf'
  cyan:     '#56b6c2'
  white:    '#c8ccd4'
  yellow:   '#e5c07b'
  red:      '#e06c75'
  green:    '#98c379'
  darkgray: '#545862'
  black:    '#282c34'
}

export def main [] {
  return {
    binary: $colors.purple
    block: $colors.blue
    cell-path: $colors.gray
    closure: $colors.cyan
    custom: $colors.white
    duration: $colors.yellow
    float: $colors.red
    glob: $colors.white
    int: $colors.purple
    list: $colors.cyan
    nothing: $colors.red
    range: $colors.yellow
    record: $colors.cyan
    string: $colors.green
    bool: {|| if $in { $colors.cyan } else { $colors.yellow } }
    datetime: {||
      (date now) - $in |
      if $in < 1hr {
        { fg: $colors.red attr: 'b' }
      } else if $in < 6hr {
        $colors.red
      } else if $in < 1day {
        $colors.yellow
      } else if $in < 3day {
        $colors.green
      } else if $in < 1wk {
        { fg: $colors.green attr: 'b' }
      } else if $in < 6wk {
        $colors.cyan
      } else if $in < 52wk {
        $colors.blue
      } else { 'dark_gray' }
    }

    filesize: {|e|
      if $e == 0b {
        $colors.gray
      } else if $e < 1mb {
        $colors.cyan
      } else {{ fg: $colors.blue }}
    }

    shape_and: { fg: $colors.purple attr: 'b' }
    shape_block: { fg: $colors.blue attr: 'b' }
    shape_bool: $colors.cyan
    shape_float: { fg: $colors.red attr: 'b' }
    shape_int: { fg: $colors.purple attr: 'b' }
    shape_keyword: { fg: $colors.purple attr: 'b' }
    shape_literal: $colors.blue
    shape_string: $colors.green

    foreground: $colors.gray
    background: $colors.black
    cursor: $colors.gray

    header: { fg: $colors.green attr: 'b' }
    hints: $colors.darkgray
    row_index: { fg: $colors.green attr: 'b' }
    search_result: { fg: $colors.red bg: $colors.gray }
    separator: $colors.gray
  }
}

export def --env "set color_config" [] {
  $env.config.color_config = (main)
}

export def "update terminal" [] {
  let theme = (main)

  let base16_palette = [
    $colors.black
    $colors.red
    $colors.green
    $colors.yellow
    $colors.blue
    $colors.purple
    $colors.cyan
    $colors.gray
    $colors.darkgray
    $colors.red
    $colors.green
    $colors.yellow
    $colors.blue
    $colors.purple
    $colors.cyan
    $colors.white
  ]

  let osc_sequences = $base16_palette
    | enumerate
    | each {|color| $"\e]4;(char -i $color.index);($color.item)\e\\" }
    | append $"\e]10;($theme.foreground)\e\\"
    | append $"\e]11;($theme.background)\e\\"
    | append $"\e]12;($theme.cursor)\e\\"

  print -n $"($osc_sequences | str join '')\r"
}

export module activate {
  export-env {
    set color_config
    update terminal
  }
}

use activate
