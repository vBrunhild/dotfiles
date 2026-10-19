{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.ov-usql = {wlib, ...}: {
    imports = [wlib.wrapperModules.ov];
    binName = "ov-usql";
    flags = {
      "--align" = true;
      "--alternate-rows" = true;
      "--column-delimiter" = "|";
      "--column-rainbow" = true;
      "--header" = "1";
      "--wrap=false" = true;
    };
  };

  flake.wrappers.usql = {
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];
    package = lib.mkDefault pkgs.usql;
    flags."--config" = "${./config.yaml}";
    env.PAGER = "${wrappers.ov-usql.wrap {inherit pkgs;}}/bin/ov-usql";
  };

  flake.modules.nixos.usql = {
    imports = [wrappers.usql.install];
    wrappers.usql.enable = true;
  };
}
