{ pkgs, ... }:
{
  environment.sessionVariables.FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";

  fonts = {
    packages = [
      pkgs.comfortaa
      pkgs.comic-neue
      pkgs.dejavu_fonts
      pkgs.inter
      pkgs.jost
      pkgs.lato
      pkgs.lexend
      pkgs.material-design-icons
      pkgs.material-icons
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-emoji
      pkgs.roboto
      pkgs.source-sans
      pkgs.twemoji-color-font
      pkgs.work-sans
    ];

    enableDefaultPackages = false;

    fontconfig = {
      defaultFonts = {
        monospace = [
          "JetBrainsMono"
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Lexend"
          "Noto Color Emoji"
        ];
        serif = [
          "Noto Serif"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
