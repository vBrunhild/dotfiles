{
  description = "My dev flake for Php!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    allPkgs = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [inputs.rust-overlay.overlays.default];
        }
    );
  in {
    devShells = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
        toolchain = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };

        phpantom-lsp = rustPlatform.buildRustPackage {
          pname = "phpantom_lsp";
          version = "0.7.0";
          src = pkgs.fetchFromGitHub {
            owner = "AJenbo";
            repo = "phpantom_lsp";
            rev = "0.7.0";
            hash = "sha256-ZmtOdoxXkwn2IDg7RyQ9KG0RNz5mrGDMcESfcOSR3Ig=";
          };
          cargoHash = "sha256-pXP4qItYgmUXVx9XwMdS6WLVc5lP7P4VX9+0TbhYrUc=";
          doCheck = false;
        };
      in {
        default = pkgs.mkShell {
          buildInputs = [
            phpantom-lsp
          ];
        };
      }
    );
  };
}
