let
  playwright-cli = pkgs: pkgs.callPackage ./_package.nix {};
in {
  perSystem = {pkgs, ...}: {
    packages.playwright-cli = playwright-cli pkgs;
  };

  flake.modules.nixos.playwright-cli = {pkgs, ...}: {
    environment.systemPackages = [(playwright-cli pkgs)];
  };
}
