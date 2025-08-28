{
  description = "My dev flake for C/C++!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            pkgs.mkShell.override
              {
                stdenv = pkgs.clangStdenv;
              }
              {
                buildInputs = [
                  pkgs.bear
                  pkgs.clang-tools
                  pkgs.cmake
                  pkgs.cppcheck
                  pkgs.doxygen
                  pkgs.gdb
                  pkgs.gtest
                  pkgs.lcov
                  pkgs.libgcc
                  pkgs.samply
                  pkgs.valgrind
                ];
              };
        }
      );
    };
}
