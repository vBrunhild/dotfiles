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
        deco = pkgs.callPackage ./deco.nix {};
        morpheus = pkgs.callPackage ./morpheus.nix {};
        groovy-language-server = pkgs.callPackage ./groovy-language-server.nix {jre = pkgs.jdk17;};
        npm-groovy-lint = pkgs.callPackage ./npm-groovy-lint.nix {};
      in {inherit deco morpheus groovy-language-server npm-groovy-lint;}
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = self.packages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.jdk17
            pkgs.groovy
            packages.deco
            packages.morpheus
            packages.groovy-language-server
            packages.npm-groovy-lint
          ];

          JAVA_HOME = "${pkgs.jdk17}";
          GROOVY_HOME = "${pkgs.groovy}";
        };
      }
    );
  };
}
