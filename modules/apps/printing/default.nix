{inputs, ...}: {
  flake.modules.nixos.printing = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        hplip-py312 = final.callPackage ./_hplip.nix {
          # https://github.com/NixOS/nixpkgs/pull/575319, see the nixpkgs-hplip input
          hplip = final.callPackage "${inputs.nixpkgs-hplip}/pkgs/by-name/hp/hplip/package.nix" {};
        };
      })
    ];

    environment.systemPackages = [pkgs.hplip-py312];

    services.printing = {
      enable = true;
      drivers = [pkgs.hplip-py312];
    };
  };
}
