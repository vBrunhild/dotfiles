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

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nu-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    neovim = {
      url = "path:./flakes/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zellij-plugins = {
      url = "path:./flakes/zellij-plugins";
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

    allPkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
        packages = user.packages {inherit pkgs;};
      in
        packages // {neovim = inputs.neovim.packages.${system}.default;}
    );

    formatter = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
      in (pkgs.alejandra)
    );

    nixosModules =
      {
        system = import ./system;
        user = user.module;

        determinate = inputs.determinate.nixosModules.default;
        home-manager = inputs.home-manager.nixosModules.home-manager;
        stylix = inputs.stylix.nixosModules.stylix;
      }
      // import ./modules;

    nixosConfigurations = import ./hosts inputs;
  };
}
