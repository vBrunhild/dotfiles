{config, ...}: let
  inherit (config) meta;
  inherit (config.flake) wrappers;
in {
  flake.wrappers.nh = {wlib, ...}: {
    imports = [wlib.wrapperModules.nh];
    flake = meta.dotfiles;
  };

  flake.modules.nixos.nh = {
    imports = [wrappers.nh.install];
    wrappers.nh.enable = true;
  };
}
