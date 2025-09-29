{
  pkgs,
  ...
}:
{
  users = {
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = "/persist/secrets/root";
      brunhild = {
        isNormalUser = true;
        homix = true;
        shell = pkgs.nushell;

        hashedPasswordFile = "/persist/secrets/brunhild";
        extraGroups = [
          "audio"
          "docker"
          "input"
          "lp"
          "networkmanager"
          "nix"
          "plugdev"
          "power"
          "systemd-journal"
          "vboxusers"
          "video"
          "wheel"
        ];
        uid = 1000;
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      extraRules = [
        {
          commands =
            builtins.map
              (command: {
                command = "/run/current-system/sw/bin/${command}";
                options = [ "NOPASSWD" ];
              })
              [
                "bandwhich"
                "nix-env"
                "nixos-rebuild"
                "poweroff"
                "reboot"
                "systemctl"
              ];

          groups = [ "wheel" ];
        }
      ];
    };
  };
}
