{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    bitbucket-cli = {
      url = "github:avivsinai/bitbucket-cli?ref=v0.32.1";
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

      bitbucket-cli = pkgs.buildGoModule {
        pname = "bitbucket-cli";
        version = "0.32.1";
        src = inputs.bitbucket-cli;
        vendorHash = "sha256-9wjEq4a5snJJ4uD4y+O3wJ15vVNs6Mcu8JVG43n94To=";

        ldflags = [
          "-s"
          "-w"
        ];

        doCheck = false;
      };
    in {
      inherit bitbucket-cli;
      default = bitbucket-cli;
    });

    checks = forAllSystems (system: {
      inherit (self.packages.${system}) default;
    });
  };
}
