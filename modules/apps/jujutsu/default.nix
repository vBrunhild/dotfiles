{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.jujutsu = {wlib, ...}: {
    imports = [wlib.wrapperModules.jujutsu];
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
  };

  flake.modules.nixos.jujutsu = {
    imports = [wrappers.jujutsu.install];
    wrappers.jujutsu.enable = true;
  };
}
