{config, ...}: let
  inherit (config.meta) dotfiles username;
  hm = config.flake.modules.homeManager;
in {
  flake.modules.nixos.boring = {pkgs, ...}: {
    environment.systemPackages = [pkgs.boring];
    home-manager.users.${username}.imports = [hm.boring];
  };

  flake.modules.homeManager.boring = {config, ...}: {
    xdg.configFile."boring/.boring.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/modules/apps/boring/boring.toml";
  };
}
