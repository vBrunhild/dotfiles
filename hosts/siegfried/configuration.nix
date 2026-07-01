{pkgs, ...}: {
  system.stateVersion = "25.11";
  console.keyMap = "br-abnt2";
  security.rtkit.enable = true;

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          FastConnectable = true;
        };
      };
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [pkgs.intel-media-driver];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  boot.kernelParams = ["i915.enable_guc=2"];

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

    # wireguard.interfaces = {
    #   wg0 = {
    #     ips = ["10.13.13.43/32"];
    #     privateKeyFile = "/etc/nixos/wireguard/private.key";
    #
    #     postSetup = ''
    #       ${pkgs.networkmanager}/bin/nmcli connection modify wg0 ipv4.dns "1.1.1.1"
    #     '';
    #     postShutdown = ''
    #       ${pkgs.networkmanager}/bin/nmcli connection modify wg0 ipv4.dns ""
    #     '';
    #
    #     peers = [
    #       {
    #         publicKey = "q2J15Qa4HwLP5frmkHbP0gCft8FkTl8EcLXfxF1M/RE=";
    #         presharedKeyFile = "/etc/nixos/wireguard/preshared.key";
    #         endpoint = "brsp.agencehost.com.br:51820";
    #         allowedIPs = [
    #           "10.13.13.0/24"
    #           "54.233.118.84/32"
    #           "136.248.80.212/32"
    #           "38.105.232.166/32"
    #           "86.48.24.118/32"
    #           "66.94.98.233/32"
    #           "146.235.27.79/32"
    #           "167.234.244.152/32"
    #         ];
    #         persistentKeepalive = 25;
    #       }
    #     ];
    #   };
    # };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];

    config = {
      niri = {
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.Screencast" = ["hyprland" "gnome"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland" "gnome"];
      };
    };
  };
}
