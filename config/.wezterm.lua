local wezterm = require("wezterm")

local config = wezterm.config_builder()

local palette = {
    -- Core
    black        = "#000000",
    white        = "#fffefe",
    fg           = "#abb2bf",
    bg           = "#282c34",
    -- Cursor & selection
    cursor       = "#c678dd",
    cursor_border= "#5c6370",
    selection_bg = "#abb2bf",
    selection_fg = "#282c34",
    -- Standard ANSI colors
    red          = "#e06c75",
    green        = "#98c379",
    yellow       = "#e5c07b",
    blue         = "#61afef",
    magenta      = "#c678dd",
    cyan         = "#56b6c2",
    -- Extended / indexed
    orange       = "#d19a66",
    dark_red     = "#be5046",
    bg1          = "#353b45",
    bg2          = "#3e4451",
    bg3          = "#565c64",
    fg_light     = "#b6bdca",
}

config.colors = {
  background    = palette.bg,
  foreground    = palette.fg_light,
  cursor_bg     = palette.cursor,
  cursor_fg     = palette.black,
  -- cursor_border = palette.cursor_border,
  -- selection_bg  = palette.selection_bg,
  -- selection_fg  = palette.selection_fg,
  ansi = {
    palette.black,
    palette.red,
    palette.green,
    palette.yellow,
    palette.blue,
    palette.magenta,
    palette.cyan,
    palette.fg_light,
  },
  brights = {
    palette.fg_light,
    palette.red,
    palette.green,
    palette.yellow,
    palette.blue,
    palette.magenta,
    palette.cyan,
    palette.white,
  },
  indexed = {
    [16] = palette.orange,
    [17] = palette.dark_red,
    -- [18] = palette.bg1,
    -- [19] = palette.bg2,
    -- [20] = palette.bg3,
    -- [21] = palette.fg_light,
  }
}

config.animation_fps = 1
config.enable_tab_bar = false
config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Noto Emoji" })
config.font_size = 9.2
config.front_end = "Software"
config.text_background_opacity = 0.5
config.window_background_opacity = 0.90
config.window_decorations = "RESIZE"

local wsl_domains = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl_domains) do
    if domain.name == "WSL:NixOS" then
        config.default_domain = "WSL:NixOS"
    end
end

return config
