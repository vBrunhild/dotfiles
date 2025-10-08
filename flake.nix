{
  inputs = {
    derterminate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixos-wsl.url = "github:nix-community/nixos-wsl/release-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    user = import ./user;

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = [inputs.neovim-nightly-overlay.overlays.default];
      };

    allPkgs = forAllSystems mkPkgs;
  in {
    packages = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
      in (user.packages {inherit inputs pkgs;})
    );

    formatter = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
      in (pkgs.alejandra)
    );

    devShells = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
      in {default = user.shell pkgs;}
    );

    nixosModules =
      {
        system = import ./system;
        user = user.module;
        determinate = inputs.derterminate.nixosModules.default;
      }
      // import ./modules;

    nixosConfigurations = import ./hosts inputs;
  };
}
