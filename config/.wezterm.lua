local wezterm = require('wezterm')

return {
    window_background_opacity = 0.90,
    text_background_opacity = 0.90,
    color_scheme = 'One Dark (Gogh)',
    font = wezterm.font_with_fallback { 'JetBrains Mono', 'Noto Emoji' },
    font_size = 9.2,
    enable_tab_bar = false,
    window_state = 'FullScreen'
}

