{config, ...}: let
  palette = config.palette.withHashtag;
  inherit (config.theme) cursor fonts icons;
in {
  flake.modules.nixos.gtk = {
    lib,
    pkgs,
    ...
  }: let
    shade = "rgba(0, 0, 0, 0.07)";

    shades = name: color:
      lib.genList (i: "@define-color ${name}_${toString (i + 1)} ${color};") 5;

    colors = with palette;
      lib.concatLines ([
          "@define-color accent_color ${primary};"
          "@define-color accent_bg_color ${primary};"
          "@define-color accent_fg_color ${background};"
          "@define-color destructive_color ${red};"
          "@define-color destructive_bg_color ${red};"
          "@define-color destructive_fg_color ${background};"
          "@define-color success_color ${cyan};"
          "@define-color success_bg_color ${cyan};"
          "@define-color success_fg_color ${background};"
          "@define-color warning_color ${purple};"
          "@define-color warning_bg_color ${purple};"
          "@define-color warning_fg_color ${background};"
          "@define-color error_color ${red};"
          "@define-color error_bg_color ${red};"
          "@define-color error_fg_color ${background};"
          "@define-color window_bg_color ${background};"
          "@define-color window_fg_color ${white};"
          "@define-color view_bg_color ${background};"
          "@define-color view_fg_color ${white};"
          "@define-color headerbar_bg_color ${black};"
          "@define-color headerbar_fg_color ${white};"
          "@define-color headerbar_border_color alpha(${black}, 0.7);"
          "@define-color headerbar_backdrop_color @window_bg_color;"
          "@define-color headerbar_shade_color ${shade};"
          "@define-color headerbar_darker_shade_color ${shade};"
          "@define-color sidebar_bg_color ${black};"
          "@define-color sidebar_fg_color ${white};"
          "@define-color sidebar_backdrop_color @window_bg_color;"
          "@define-color sidebar_shade_color ${shade};"
          "@define-color secondary_sidebar_bg_color @sidebar_bg_color;"
          "@define-color secondary_sidebar_fg_color @sidebar_fg_color;"
          "@define-color secondary_sidebar_backdrop_color @sidebar_backdrop_color;"
          "@define-color secondary_sidebar_shade_color @sidebar_shade_color;"
          "@define-color card_bg_color ${black};"
          "@define-color card_fg_color ${white};"
          "@define-color card_shade_color ${shade};"
          "@define-color dialog_bg_color ${black};"
          "@define-color dialog_fg_color ${white};"
          "@define-color popover_bg_color ${black};"
          "@define-color popover_fg_color ${white};"
          "@define-color popover_shade_color ${shade};"
          "@define-color shade_color ${shade};"
          "@define-color scrollbar_outline_color ${dark-gray};"
        ]
        ++ shades "blue" primary
        ++ shades "green" cyan
        ++ shades "yellow" yellow
        ++ shades "orange" orange
        ++ shades "red" red
        ++ shades "purple" purple
        ++ shades "light" white
        ++ shades "dark" white);

    theme = pkgs.runCommand "palette-gtk-theme" {} ''
      for gtk in gtk-3.0 gtk-4.0; do
        dir=$out/share/themes/Palette/$gtk
        mkdir -p $dir
        cp -r ${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark/$gtk/. $dir/
        chmod -R u+w $dir
        mv $dir/gtk.css $dir/adw-gtk3.css
        {
          echo '@import url("adw-gtk3.css");'
          cat ${pkgs.writeText "palette.css" colors}
        } > $dir/gtk.css
        cp $dir/gtk.css $dir/gtk-dark.css
      done
    '';

    settings = {
      gtk-cursor-theme-name = cursor.name;
      gtk-cursor-theme-size = cursor.size;
      gtk-font-name = "${fonts.sansSerif} ${toString fonts.size}";
      gtk-icon-theme-name = icons.name;
      gtk-theme-name = "Palette";
    };

    settingsIni = lib.generators.toINI {} {Settings = settings;};
  in {
    environment.systemPackages = [theme];

    environment.etc = {
      "xdg/gtk-3.0/settings.ini".text = settingsIni;
      "xdg/gtk-4.0/settings.ini".text = settingsIni;
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            cursor-size = lib.gvariant.mkInt32 cursor.size;
            cursor-theme = cursor.name;
            font-name = "${fonts.sansSerif} ${toString fonts.size}";
            gtk-theme = "Palette";
            icon-theme = icons.name;
            monospace-font-name = "${fonts.monospace} ${toString fonts.size}";
          };
        }
      ];
    };
  };
}
