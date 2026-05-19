{
  config,
  pkgs,
  ...
}: let
  palette = config.palette;
in {
  palette = {
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
  };

  stylix = {
    enable = true;
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
    };

    fonts = {
      serif = {
        package = pkgs.inter;
        name = "Inter";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    base16Scheme = {
      base00 = palette.background;
      base01 = palette.black;
      base02 = palette.dark-gray;
      base03 = palette.light-gray;
      base04 = "#abb2bf";
      base05 = palette.white;
      base06 = palette.foreground;
      base07 = "#c8ccd4";
      base08 = palette.red;
      base09 = palette.orange;
      base0A = palette.yellow;
      base0B = palette.cyan;
      base0C = palette.blue;
      base0D = palette.primary;
      base0E = palette.purple;
      base0F = "#be5046";
    };
  };

  # https://github.com/nix-community/stylix/issues/2334
  stylix.targets.kmscon.enable = false;
}
