{inputs, ...}: let
  bitbucket-cli = pkgs:
    pkgs.buildGoModule {
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
  perSystem = {pkgs, ...}: {
    packages.bitbucket-cli = bitbucket-cli pkgs;
  };

  flake.modules.nixos.bitbucket-cli = {pkgs, ...}: {
    environment.systemPackages = [(bitbucket-cli pkgs)];
  };
}
