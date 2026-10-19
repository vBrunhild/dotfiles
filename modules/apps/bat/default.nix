{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.bat = {
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];
    package = lib.mkDefault pkgs.bat;
    env.BAT_CONFIG_PATH = "${./config.rc}";
  };

  flake.modules.nixos.bat = {
    imports = [wrappers.bat.install];
    wrappers.bat.enable = true;
  };
}
