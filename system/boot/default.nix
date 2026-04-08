{ ... }:
{
  boot = {
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    loader.grub.configurationLimit = 10;
  };
}
