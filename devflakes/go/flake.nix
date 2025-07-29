{
  description = "My dev flake for Go!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.go
            pkgs.delve
            pkgs.gopls
            pkgs.golangci-lint
            pkgs.golangci-lint-langserver
            pkgs.go-tools
          ];
        };
      }
    );
  };
}
