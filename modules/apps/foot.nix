{config, ...}: let
  inherit (config) palette;
  inherit (config.flake) wrappers;
in {
  perSystem = {pkgs, ...}: {
    wrappers.packages.foot = !pkgs.stdenv.hostPlatform.isLinux;
  };

  flake.wrappers.foot = {wlib, ...}: {
    imports = [wlib.wrapperModules.foot];

    settings = {
      main = {
        font = "monospace:size=9";
        pad = "10x10";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3.0;
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors-dark = {
        inherit (palette) background foreground;
        alpha = 0.90;
        regular0 = palette.black;
        regular1 = palette.red;
        regular2 = palette.green;
        regular3 = palette.yellow;
        regular4 = palette.blue;
        regular5 = palette.purple;
        regular6 = palette.cyan;
        regular7 = palette.white;
        bright0 = palette.light-gray;
        bright1 = palette.red;
        bright2 = palette.green;
        bright3 = palette.yellow;
        bright4 = palette.blue;
        bright5 = palette.purple;
        bright6 = palette.cyan;
        bright7 = palette.dark-gray;
      };
    };
  };

  flake.modules.nixos.foot = {
    imports = [wrappers.foot.install];
    wrappers.foot.enable = true;
  };
}
