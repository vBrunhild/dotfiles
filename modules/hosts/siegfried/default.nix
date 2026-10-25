{config, ...}: let
  modules = config.flake.modules.nixos;
in {
  configurations.nixos.siegfried.module = {pkgs, ...}: {
    imports = [
      ./_hardware.nix
      modules.base
      modules.cli
      modules.desktop
      modules.zerotier
    ];

    system.stateVersion = "25.11";
    console.keyMap = "br-abnt2";
    hardware.enableAllFirmware = true;

    hardware.graphics = {
      enable = true;
      extraPackages = [pkgs.intel-media-driver];
    };
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = ["i915.enable_guc=2"];
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };
  };
}
