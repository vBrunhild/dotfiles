{config, ...}: let
  inherit (config) palette;
  inherit (config.flake) wrappers;
in {
  perSystem = {pkgs, ...}: {
    wrappers.packages.niri = !pkgs.stdenv.hostPlatform.isLinux;
  };

  flake.wrappers.niri = {
    pkgs,
    wlib,
    ...
  }: let
    theme =
      pkgs.writeText "niri-theme.kdl"
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
  in {
    imports = [wlib.wrapperModules.niri];

    "config.kdl".content =
      builtins.replaceStrings
      [''include optional=true "theme.kdl"'']
      [''include "${theme}"'']
      (builtins.readFile ./config.kdl);
  };

  flake.modules.nixos.niri = {
    config,
    pkgs,
    ...
  }: {
    imports = [wrappers.niri.install];
    wrappers.niri.enable = true;

    programs.niri = {
      enable = true;
      package = config.wrappers.niri.wrapper;
    };

    environment.systemPackages = [pkgs.xwayland-satellite];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        };
      };
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
  };
}
