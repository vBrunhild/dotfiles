{...}: {
  homix = {
    ".config/bat/config".source = ./bat/config.rc;
    ".config/bottom/bottom.toml".source = ./bottom/config.toml;
    ".config/flameshot/flameshot.ini".source = ./flameshot/flameshot.ini;
    ".config/jj/config.toml".source = ./jj/config.toml;
    ".config/niri/config.kdl".source = ./niri/config.kdl;
    ".config/spotify-player/app.toml".source = ./spotify_player/app.toml;
    ".config/zellij/config.kdl".source = ./zellij/config.kdl;
    ".config/zellij/layouts/default.kdl".source = ./zellij/layouts/default.kdl;
    ".ripgreprc".source = ./rigprep/config.rc;
  };

  imports = [
    ./nushell
  ];
}
