{
  description = "My dev flake for Rust!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wild = {
      url = "github:davidlattimore/wild";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      wild,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ (import wild) ];
        };

      allPkgs = forAllSystems pkgsFor;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = allPkgs.${system};
          wildStdenv = pkgs.useWildLinker pkgs.stdenv;
        in
        {
          default = pkgs.mkShell.override { stdenv = wildStdenv; } {
            packages = [
              pkgs.rustc
              pkgs.cargo
              pkgs.rust-analyzer
              pkgs.clippy
            ];
          };
        }
      );
    };
}
