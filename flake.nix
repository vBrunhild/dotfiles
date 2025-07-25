{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, self, ... }:
  let
    user = import ./user;

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in (user.packages pkgs)
    );

    formatter = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in pkgs.alejandra
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in { default = user.shell pkgs; }
    );

    nixosModules = {
      system = import ./system;
      user = user.module;
    } // import ./modules;

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        inputs.nixos-wsl.nixosModules.default {
          wsl = {
            enable = true;
            wslConf.automount.root = "/mnt";
            defaultUser = "brunhild";
          };

          system.stateVersion = "24.11";
        }
      ] ++ builtins.attrValues self.nixosModules;

      specialArgs = {
        inherit inputs;
        flake = self;
      };
    };
  };
}
