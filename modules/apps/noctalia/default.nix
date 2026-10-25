{config, ...}: let
  palette = config.palette.withHashtag;
  inherit (config.flake) wrappers;

  colors = with palette; {
    dark = {
      mPrimary = primary;
      mOnPrimary = background;
      mSecondary = secondary;
      mOnSecondary = background;
      mTertiary = blue;
      mOnTertiary = background;
      mError = red;
      mOnError = background;
      mSurface = background;
      mOnSurface = white;
      mSurfaceVariant = black;
      mOnSurfaceVariant = foreground;
      mOutline = light-gray;
      mShadow = background;
      mHover = blue;
      mOnHover = background;

      terminal = {
        inherit background foreground;
        cursor = foreground;
        cursorText = background;
        selectionBg = dark-gray;
        selectionFg = white;
        normal = {
          inherit black red green yellow blue cyan white;
          magenta = purple;
        };
        bright = {
          inherit red green yellow blue cyan;
          black = light-gray;
          magenta = purple;
          white = dark-gray;
        };
      };
    };
  };
in {
  perSystem = {pkgs, ...}: {
    wrappers.packages.noctalia = !pkgs.stdenv.hostPlatform.isLinux;
  };

  flake.wrappers.noctalia = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];

    package = lib.mkDefault pkgs.noctalia;

    env.NOCTALIA_CONFIG_HOME = "${placeholder config.outputName}/noctalia-config";

    constructFiles = {
      config = {
        relPath = "noctalia-config/noctalia/config.toml";
        content = builtins.readFile ./config.toml;
      };

      palette = {
        relPath = "noctalia-config/noctalia/palettes/palette.json";
        content = builtins.toJSON colors;
      };
    };
  };

  flake.modules.nixos.noctalia = {
    imports = [wrappers.noctalia.install];
    wrappers.noctalia.enable = true;
  };
}
