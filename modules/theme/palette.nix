{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  names = [
    "primary"
    "secondary"
    "background"
    "foreground"

    "black"
    "dark-gray"
    "light-gray"
    "white"

    "blue"
    "orange"
    "cyan"
    "green"
    "purple"
    "red"
    "yellow"
  ];

  colors = lib.genAttrs names;

  mkColorOption = name:
    mkOption {
      description = "Palette ${name}";
      type = types.str;
      apply = lib.removePrefix "#";
    };
in {
  options.palette =
    (colors mkColorOption)
    // {
      withHashtag = mkOption {
        description = "Palette colors with # prefix";
        type = types.attrsOf types.str;
        readOnly = true;
      };

      lib = mkOption {
        description = "Color helpers";
        type = types.attrsOf types.raw;
        readOnly = true;
      };
    };

  config.palette = {
    primary = "#98c379";
    secondary = "#c678dd";
    background = "#282c34";
    foreground = "#b6bdca";

    black = "#1e2127";
    dark-gray = "#3e4451";
    light-gray = "#545862";
    white = "#cdd4e1";

    blue = "#61afef";
    orange = "#d19a66";
    cyan = "#56b6c2";
    green = "#98c379";
    purple = "#c678dd";
    red = "#e06c75";
    yellow = "#e5c07b";

    withHashtag = colors (name: "#${config.palette.${name}}");
    lib = import ./_palette-lib.nix {inherit lib;};
  };
}
