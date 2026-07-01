{
  inputs,
  lib,
  pkgs,
  ...
}: let
  sources = {
    official = {
      name = "Official Noctalia Plugins";
      url = "https://github.com/noctalia-dev/noctalia-plugins";
    };
  };

  plugins = {
    clipper = {
      state = {
        enable = true;
        sourceUrl = sources.official.url;
      };
    };

    screen-toolkit = {
      state = {
        enable = true;
        sourceUrl = sources.official.url;
      };
      packages = [
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
      state = {
        enable = true;
        sourceUrl = sources.official.url;
      };
      packages = [pkgs.evtest];
      extraGroups = ["input"];
    };
  };

  enabledPlugins =
    plugins
    |> lib.filterAttrs (_: p: p.state.enable or false);

  pluginStates =
    enabledPlugins
    |> lib.mapAttrs (_: p: p.state);

  allPackages =
    enabledPlugins
    |> lib.attrValues
    |> lib.concatMap (p: p.packages or []);

  allGroups =
    enabledPlugins
    |> lib.attrValues
    |> lib.concatMap (p: p.extraGroups or []);
in {
  home-manager.users.brunhild = {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia-shell = {
      enable = true;
      settings =
        ./config.json
        |> builtins.readFile
        |> builtins.fromJSON
        |> lib.mapAttrsRecursive (_: lib.mkDefault);

      plugins = {
        sources =
          sources
          |> lib.mapAttrsToList (_: src: {
            enabled = true;
            inherit (src) name url;
          });

        states = pluginStates;
      };
    };
  };

  environment.systemPackages = allPackages;
  users.users.brunhild.extraGroups = allGroups;
}
