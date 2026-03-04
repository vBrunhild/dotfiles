{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixos-wsl.url = "github:nix-community/nixos-wsl/release-25.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    nixosModules = {
      system = import ./system;
      user = user.module;

      determinate = inputs.determinate.nixosModules.default;
      home-manager = inputs.home-manager.nixosModules.home-manager;
    };

    nixosConfigurations = import ./hosts inputs;
  };
}
