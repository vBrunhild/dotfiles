{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.meta = {
    username = mkOption {
      type = types.str;
      default = "brunhild";
    };

    email = mkOption {
      type = types.str;
      default = "brunomoretti100@gmail.com";
    };

    gitName = mkOption {
      type = types.str;
      default = "vBrunhild";
    };

    dotfiles = mkOption {
      type = types.str;
      default = "/home/brunhild/dotfiles";
      description = "Location of this repository on disk, for out-of-store symlinks";
    };

    timeZone = mkOption {
      type = types.str;
      default = "America/Campo_Grande";
    };
  };
}
