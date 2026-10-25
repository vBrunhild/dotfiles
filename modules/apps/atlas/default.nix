let
  atlas = pkgs: pkgs.callPackage ./_package.nix {};
in {
  perSystem = {pkgs, ...}: {
    packages.atlas = atlas pkgs;
  };

  flake.modules.nixos.atlas = {pkgs, ...}: {
    environment.systemPackages = [(atlas pkgs)];
  };
}
