{
  config,
  lib,
  ...
}: {
  perSystem = {system, ...}: {
    checks =
      config.flake.nixosConfigurations
      |> lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system)
      |> lib.mapAttrs' (name: host: lib.nameValuePair "nixos-${name}" host.config.system.build.toplevel);
  };
}
