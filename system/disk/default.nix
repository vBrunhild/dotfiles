{ ... }:
{
  staypls = {
    enable = true;
    dirs = ["/etc/ssh" "/etc/nix"];
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=1G" "mode=755"];
  };

  fileSystems."/nix" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@nix" "compress=zstd"];
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@tmp"];
  };

  fileSystems."/persist" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@persist" "compress=zstd"];
  };

  fileSystems."/home" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@home" "compress=zstd"];
  };

  swapDevices = [
    {
      device = "/persist/swap";
      size = 8 * 1024;
    }
  ];
}
