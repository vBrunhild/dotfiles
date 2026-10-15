{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";

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

    allPkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (system: let
      pkgs = allPkgs.${system};
      craneLib = inputs.crane.mkLib pkgs;
      inherit (pkgs) callPackage;

      neovim = callPackage ./neovim.nix {
        flake = self;
      };

      path-server = callPackage ./path-server.nix {
        inherit inputs craneLib;
      };
    in {
      inherit neovim path-server;
      default = neovim;
    });

    checks = forAllSystems (system: {
      inherit (self.packages.${system}) neovim path-server;
    });
  };
}
