{inputs, ...}: {
  flake.modules.nixos.delta = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
