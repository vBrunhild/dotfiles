{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }: 
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem  {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default {
            system.stateVersion = "24.11";
            wsl.enable = true;
            wsl.defaultUser = "brunhild";
          }
          ./configuration.nix
        ];
      };
    };
  };
}
