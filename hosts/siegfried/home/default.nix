{inputs, ...}: {
  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    settings = {
      theme = "dark";
    };

    session = {
      isLightMode = false;
    };
  };

  programs.satty = {
    enable = true;
    settings = {
      general = {
        fullscreen = false;
        copy-command = "wl-copy";
        output-filename = "/tmp/screenshot-%Y-%m-%dT%H-%M-%S.png";
        disable-notifications = true;
      };
    };
  };

  services = {
    cliphist.enable = true;
  };

  imports = [
    ./theme.nix
    inputs.dms.homeModules.dank-material-shell
    inputs.noctalia.homeModules.default
  ];
}
