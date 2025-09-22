{...}: {
  homix = {
    ".config/bat/config".source = ./bat/config.rc;
    ".config/bottom/bottom.toml".source = ./bottom/config.toml;
    ".config/jj/config.toml".source = ./jj/config.toml;
    ".config/wezterm/wezterm.lua".source = ./wezterm/config.lua;
    ".config/zellij/config.kdl".source = ./zellij/config.kdl;
    ".config/zellij/layouts/default.kdl".source = ./zellij/layouts/default.kdl;
    ".ripgreprc".source = ./rigprep/config.rc;
  };

  imports = [
    ./nushell
  ];
}
