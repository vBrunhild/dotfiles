{
  flake.modules.nixos.dev-tools = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.ansible
      pkgs.cloudflared
      pkgs.deploy-rs
      pkgs.gh
      pkgs.just
      pkgs.mutagen
      pkgs.opentofu
    ];
  };
}
