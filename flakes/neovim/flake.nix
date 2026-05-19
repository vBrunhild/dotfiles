{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    path-server = {
      url = "github:kunlinglio/path-server";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    allPkgs = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [inputs.neovim-nightly-overlay.overlays.default];
      });
  in {
    packages = forAllSystems (system: let
      pkgs = allPkgs.${system};
      craneLib = inputs.crane.mkLib pkgs;
      inherit (pkgs) callPackage;

      neovim = callPackage ./neovim.nix {
        inherit inputs;
        flake = self;
      };

      path-server = callPackage ./path-server.nix {
        inherit inputs craneLib;
      };
    in {
      inherit
        neovim
        path-server
        ;

      default = neovim;
    });

    checks = forAllSystems (system: {
      inherit
        (self.packages.${system})
        neovim
        path-server
        ;
    });
  };
}
