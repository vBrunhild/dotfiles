{
  description = "My dev flake for Php!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    pkgsFor = system:
      import nixpkgs {inherit system;};

    allPkgs = forAllSystems pkgsFor;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = allPkgs.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.laravel
            pkgs.php
            pkgs.php84Packages.psalm
            pkgs.phpactor
          ];
        };
      }
    );
  };
}
