{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.bottom = {wlib, ...}: {
    imports = [wlib.wrapperModules.bottom];
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
  };

  flake.modules.nixos.bottom = {
    imports = [wrappers.bottom.install];
    wrappers.bottom.enable = true;
  };
}
