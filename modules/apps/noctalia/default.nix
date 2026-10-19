{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config) palette;
  inherit (config.flake) wrappers;
  inherit (config.meta) username;

  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";

  plugins = {
    clipper = {};

    screen-toolkit = {
      packages = pkgs: [
        pkgs.curl
        pkgs.ffmpeg
        pkgs.grim
        pkgs.imagemagick
        pkgs.jq
        pkgs.slurp
        pkgs.tesseract
        pkgs.translate-shell
        pkgs.wl-screenrec
        pkgs.zbar
      ];
    };

    show-keys = {
      packages = pkgs: [pkgs.evtest];
      extraGroups = ["input"];
    };
  };
in {
  perSystem = {pkgs, ...}: {
    wrappers.packages.noctalia-shell = !pkgs.stdenv.hostPlatform.isLinux;
  };

  flake.wrappers.noctalia-shell = {
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.wrapperModules.noctalia-shell];

    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = builtins.fromJSON (builtins.readFile ./config.json);

    colors = with palette.withHashtag; {
      mError = red;
      mHover = blue;
      mOnError = background;
      mOnHover = background;
      mOnPrimary = background;
      mOnSecondary = background;
      mOnSurface = white;
      mOnSurfaceVariant = "#abb2bf";
      mOnTertiary = background;
      mOutline = light-gray;
      mPrimary = primary;
      mSecondary = secondary;
      mShadow = background;
      mSurface = background;
      mSurfaceVariant = black;
      mTertiary = blue;
    };

    plugins.sources = [
      {
        enabled = true;
        name = "Official Noctalia Plugins";
        url = sourceUrl;
      }
    ];

    preInstalledPlugins =
      plugins
      |> lib.mapAttrs (name: _: {
        inherit sourceUrl;
        src = "${inputs.noctalia-plugins}/${name}";
      });
  };

  flake.modules.nixos.noctalia = {pkgs, ...}: {
    imports = [wrappers.noctalia-shell.install];
    wrappers.noctalia-shell.enable = true;

    environment.systemPackages =
      plugins
      |> lib.attrValues
      |> lib.concatMap (p: (p.packages or (_: [])) pkgs);

    users.users.${username}.extraGroups =
      plugins
      |> lib.attrValues
      |> lib.concatMap (p: p.extraGroups or []);
  };
}
