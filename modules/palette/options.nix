{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  mkColorOption = name:
    mkOption {
      description = "Palette ${name}";
      type = types.str;
      apply = lib.removePrefix "#";
    };

  colors = lib.genAttrs [
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
in {
  options.palette =
    (colors mkColorOption)
    // {
      withHashtag = mkOption {
        description = "Palette colors with # prefix";
        type = types.attrsOf types.str;
        readOnly = true;
      };
    };

  config.palette.withHashtag =
    colors (name: "#${config.palette.${name}}");
}
