{
  inputs,
  lib,
  ...
}: let
  sources = {
    official = {
      name = "Official Noctalia Plugins";
      url = "https://github.com/noctalia-dev/noctalia-plugins";
    };
  };
in {
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
        |> builtins.mapAttrs (key: src: {
          enabled = true;
          inherit (src) name ulr;
        })
        |> builtins.attrValues;

      states = {
        clipper = {
          enabled = true;
          sourceUrl = sources.official.url;
        };
        polkit-agent = {
          enable = true;
          sourceUrl = sources.official.url;
        };
      };
    };
  };
}
