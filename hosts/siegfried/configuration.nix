{pkgs, ...}: {
  system.stateVersion = "25.11";
  console.keyMap = "br-abnt2";
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [57621];
      allowedUDPPorts = [5353];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-termfilechooser
    ];

    config = {
      common = {
        "org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
      };

      niri = {
        "org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
        "org.freedesktop.impl.portal.Screencast" = ["gnome"];
      };
    };
  };
}
