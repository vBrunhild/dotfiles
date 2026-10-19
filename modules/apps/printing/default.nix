{
  flake.modules.nixos.printing = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        hplip-py312 = final.callPackage ./_hplip.nix {};
      })
    ];

    environment.systemPackages = [pkgs.hplip-py312];

    services.printing = {
      enable = true;
      drivers = [pkgs.hplip-py312];
    };
  };
}
