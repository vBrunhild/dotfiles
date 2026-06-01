{
  config,
  inputs,
  ...
}: let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles/user/config";
in {
  home = rec {
    username = "brunhild";
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  programs = {
    home-manager.enable = true;
    awscli.enable = true;
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

    "boring/.boring.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/boring/boring.toml";
  };

  imports = [
    ./secrets
    inputs.agenix.homeManagerModules.default
  ];
}
