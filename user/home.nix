{...}: {
  home = rec {
    username = "brunhild";
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  programs = {
    home-manager.enable = true;
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--smart-case"
      "--hidden"
      "--glob=!.git/*"
    ];
  };

  xdg.configFile = {
    "bat/config".source = ./config/bat/config.rc;
    "bottom/bottom.toml".source = ./config/bottom/config.toml;
    "jj/config.toml".source = ./config/jj/config.toml;
    "niri/config.kdl".source = ./config/niri/config.kdl;
    "spotify-player/app.toml".source = ./config/spotify_player/app.toml;
    "zellij/config.kdl".source = ./config/zellij/config.kdl;
  };

  imports = [
    ./config/nushell
  ];
}
