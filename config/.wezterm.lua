local wezterm = require("wezterm")

local config = {
    visual_bell = {
        fade_in_duration_ms = 75,
        fade_out_duration_ms = 75,
        target = "CursorColor",
    },
    animation_fps = 1,
    audible_bell = "Disabled",
    color_scheme = "One Dark (Gogh)",
    enable_tab_bar = false,
    font = wezterm.font_with_fallback({ "JetBrains Mono", "Noto Emoji" }),
    font_size = 9.2,
    front_end = "Software",
    text_background_opacity = 0.96,
    window_background_opacity = 0.96,
    window_decorations = "RESIZE",
}

local wsl_domains = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl_domains) do
    if domain.name == "WSL:NixOS" then
        config.default_domain = "WSL:NixOS"
    end
end

return config
