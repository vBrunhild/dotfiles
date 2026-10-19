{inputs, ...}: {
  flake.modules.nixos.sem = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.sem.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
