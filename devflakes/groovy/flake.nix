{
  description = "My groovy work environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        groovy-language-server = pkgs.callPackage ./groovy-language-server.nix {jre = pkgs.jdk17;};
        npm-groovy-lint = pkgs.callPackage ./npm-groovy-lint.nix {};
      in {inherit groovy-language-server npm-groovy-lint;}
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        my-packages = self.packages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.jdk17
            pkgs.groovy
            my-packages.deco
            my-packages.morpheus
            my-packages.groovy-language-server
            my-packages.npm-groovy-lint
          ];

          JAVA_HOME = "${pkgs.jdk17}";
          GROOVY_HOME = "${pkgs.groovy}";
        };
      }
    );
  };
}
