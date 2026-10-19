{config, ...}: {
  perSystem = {pkgs, ...}: {
    packages.atlas = pkgs.callPackage ./_package.nix {};
  };

  flake.modules.nixos.atlas = {pkgs, ...}: {
    environment.systemPackages = [
      config.flake.packages.${pkgs.stdenv.hostPlatform.system}.atlas
    ];
  };
}
