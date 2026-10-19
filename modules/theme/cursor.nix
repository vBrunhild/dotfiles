{config, ...}: let
  inherit (config.theme) cursor icons;
in {
  flake.modules.nixos.cursor = {pkgs, ...}: let
    default = pkgs.writeTextDir "share/icons/default/index.theme" ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${cursor.name}
    '';
  in {
    environment.systemPackages = [
      (cursor.package pkgs)
      (icons.package pkgs)
      default
    ];

    environment.sessionVariables = {
      XCURSOR_THEME = cursor.name;
      XCURSOR_SIZE = toString cursor.size;
    };
  };
}
