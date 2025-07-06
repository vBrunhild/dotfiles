{ modulesPath, pkgs, ... }:
{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      configurationLimit = 10;
      editor = false;
    };
    timeout = 0;
    efi.canTouchEfiVariables = true;
  };

  kernelPackages = pkgs.linuxPackages_xanmod_latest;
  kernelParams = [ "nowatchdog" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = ["noatime" "discard"];
  };
}
