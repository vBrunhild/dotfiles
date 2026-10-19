{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.configurations.nixos = mkOption {
    type = types.lazyAttrsOf (types.submodule {
      options = {
        system = mkOption {
          type = types.str;
          default = "x86_64-linux";
        };

        module = mkOption {
          type = types.deferredModule;
        };
      };
    });
    default = {};
  };

  config.flake.nixosConfigurations =
    config.configurations.nixos
    |> lib.mapAttrs (name: host:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          host.module
          {
            networking.hostName = lib.mkDefault name;
            nixpkgs.hostPlatform = lib.mkDefault host.system;
          }
        ];
      });
}
