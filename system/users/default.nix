{ flake, pkgs, ... }:
{
  users = {
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = "/persist/secrets/root";
      brunhild = {
        homix = true;
        isNormalUser = true;
        shell = flake.packages.${pkgs.system}.fish;

        hashedPasswordFile = "/persist/secrets/brunhild";
        extraGroups = [
          "wheel"
          "systemd-journal"
          "vboxusers"
          "audio"
          "plugdev"
          "video"
          "input"
          "lp"
          "networkmanager"
          "power"
          "nix"
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
            builtins.map (command: {
              command = "/run/current-system/sw/bin/${command}";
              options = ["NOPASSWD"];
            })
            ["poweroff" "reboot" "nixos-rebuild" "nix-env" "bandwhich" "systemctl"];

          groups = ["wheel"];
        }
      ];
    };
  };
}
