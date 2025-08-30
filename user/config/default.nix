{...}: {
  homix = {
    ".config/.wezterm.lua".source = ./wezterm/config.lua;
    ".config/jj/config.toml".source = ./jj/config.toml;
    ".config/starship.toml".source = ./starship/config.toml;
    ".config/zellij/config.kdl".source = ./zellij/config.kdl;
    ".ripgreprc".source = ./rigprep/config.rc;
  };
}
