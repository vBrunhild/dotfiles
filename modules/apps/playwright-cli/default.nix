{config, ...}: {
  perSystem = {pkgs, ...}: {
    packages.playwright-cli = pkgs.callPackage ./_package.nix {};
  };

  flake.modules.nixos.playwright-cli = {pkgs, ...}: {
    environment.systemPackages = [
      config.flake.packages.${pkgs.stdenv.hostPlatform.system}.playwright-cli
    ];
  };
}
