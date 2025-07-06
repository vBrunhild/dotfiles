{
  nixpkgs,
  self,
  ...
}:
let
  inherit (self) inputs;
  mkHost = name: system:
    nixpkgs.lib.nixosSystem {
      modules = [  
        {
          networking.hostName = name;
          nixpkgs.hostPlatform = system;
        }
        ./${name}

        inputs.nixos-wsl.nixosModules.default {
          system.stateVersion = "24.11";
          wsl.enable = true;
          wsl.defaultUser = "brunhild";
        }
      ] ++ builtins.attrValues self.nixosModules;

      specialArgs = {
        inherit inputs;
        # theme = (import ../user).theme nixpkgs.legacyPackages.${system};
        flake = self;
      };
    };
in {
  calypso = mkHost "calypso" "x86_64-linux";
  pandora = mkHost "pandora" "aarch64-linux";
}
