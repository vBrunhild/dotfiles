{
  config,
  inputs,
  ...
}: let
  inherit (config.meta) username;
  modules = config.flake.modules.nixos;
in {
  configurations.nixos.etzel.module = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      modules.base
      modules.cli
    ];

    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = username;
    };

    system.stateVersion = "25.05";
  };
}
