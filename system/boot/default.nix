{...}:
{
  boot = {
    initrd = {
      verbose = false;
      systemd.enable = true;
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };

      timeout = 0;
    };
  };
}
