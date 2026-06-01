{config, ...}: let
  inherit (config) palette;
in {
  programs.foot = {
    enable = true;

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
}
