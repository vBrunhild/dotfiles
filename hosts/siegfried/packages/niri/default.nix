{config, ...}: let
  inherit (config) palette;
in {
  programs.niri.enable = true;

  home-manager.users.brunhild = {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
    xdg.configFile."niri/theme.kdl".text =
      # kdl
      ''
        layout {
            focus-ring {
                on
                width 1.3
                active-color "${palette.withHashtag.primary}"
                inactive-color "${palette.withHashtag.dark-gray}"
                urgent-color "${palette.withHashtag.red}"
            }
        }
      '';
  };
}
