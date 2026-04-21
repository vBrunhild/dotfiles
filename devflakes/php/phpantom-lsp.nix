{pkgs, ...}: let
  toolchain = pkgs.rust-bin.stable.latest.default;
  rustPlatform = pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
in
  rustPlatform.buildRustPackage {
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
  }
