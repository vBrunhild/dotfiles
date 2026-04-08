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
