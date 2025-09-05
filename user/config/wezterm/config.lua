local wezterm = require("wezterm")

wezterm.on("toggle-opacity", function(window, _)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_background_opacity then
        overrides.window_background_opacity = 0.90
    else
        overrides.window_background_opacity = nil
    end
    window:set_config_overrides(overrides)
end)

local config = wezterm.config_builder()

local palette = {
    -- black and white
    black          = "#282c34",
    full_black     = "#000000",
    white          = "#fffefe",
    light_gray     = "#b6bdca",
    dark_gray      = "#565c64",
    -- ansi
    red            = "#e06c75",
    green          = "#98c379",
    yellow         = "#e5c07b",
    blue           = "#61afef",
    magenta        = "#c678dd",
    cyan           = "#56b6c2",
}

config.colors = {
    background = palette.black,
    foreground = palette.light_gray,
    ansi       = {
        palette.black,
        palette.red,
        palette.green,
        palette.yellow,
        palette.blue,
        palette.magenta,
        palette.cyan,
        palette.light_gray,
    },
    brights    = {
        palette.dark_gray,
        palette.red,
        palette.green,
        palette.yellow,
        palette.blue,
        palette.magenta,
        palette.cyan,
        palette.white,
    }
}

config.window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
}

config.animation_fps = 1
config.enable_tab_bar = false
config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Noto Emoji" })
config.font_size = 9.2
config.front_end = "Software"
config.text_background_opacity = 1
config.window_decorations = "RESIZE"
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }

config.keys = {
    {
        key = "O",
        mods = "CTRL|SHIFT",
        action = wezterm.action.EmitEvent "toggle-opacity"
    }
}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    for _, domain in ipairs(wezterm.default_wsl_domains()) do
        if domain.name == "WSL:NixOS" then
            config.default_domain = "WSL:NixOS"
            break
        end
    end
end

return config
