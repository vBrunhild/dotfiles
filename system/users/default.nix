{pkgs, ...}: {
  users = {
    users = {
      brunhild = {
        uid = 1000;
        isNormalUser = true;
        shell = pkgs.nushell;

        extraGroups = [
          "audio"
          "docker"
          "input"
          "lp"
          "networkmanager"
          "nix"
          "plugdev"
          "power"
          "scanner"
          "systemd-journal"
          "vboxusers"
          "video"
          "wheel"
        ];
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      extraRules = [
        {
          commands =
            map (command: {
              command = "/run/current-system/sw/bin/${command}";
              options = ["NOPASSWD"];
            })
            [
              "bandwhich"
              "nh"
              "nix-env"
              "nixos-rebuild"
              "poweroff"
              "reboot"
              "systemctl"
            ];

          groups = ["wheel"];
        }
      ];
    };
  };
}
