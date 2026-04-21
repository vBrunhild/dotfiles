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

      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sss-nvim.url = "github:vBrunhild/simple-start-screen.nvim";
    # zjstatus.url = "github:dj95/zjstatus";
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
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          # (final: prev: {zjstatus = inputs.zjstatus.packages.${prev.system}.default;})
        ];
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

    nixosModules =
      {
        system = import ./system;
        user = user.module;

        determinate = inputs.determinate.nixosModules.default;
        home-manager = inputs.home-manager.nixosModules.home-manager;
        # niri = inputs.niri-flake.nixosModules.niri;
        stylix = inputs.stylix.nixosModules.stylix;
      }
      // import ./modules;

    nixosConfigurations = import ./hosts inputs;
  };
}
