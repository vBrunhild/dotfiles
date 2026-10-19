{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.theme = {
    cursor = {
      name = mkOption {
        type = types.str;
        default = "Bibata-Modern-Classic";
      };
      size = mkOption {
        type = types.int;
        default = 24;
      };
      package = mkOption {
        type = types.functionTo types.package;
        default = pkgs: pkgs.bibata-cursors;
      };
    };

    icons = {
      name = mkOption {
        type = types.str;
        default = "Papirus-Dark";
      };
      package = mkOption {
        type = types.functionTo types.package;
        default = pkgs: pkgs.papirus-icon-theme;
      };
    };

    fonts = {
      sansSerif = mkOption {
        type = types.str;
        default = "Inter";
      };
      monospace = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
      };
      size = mkOption {
        type = types.int;
        default = 12;
      };
    };
  };
}
