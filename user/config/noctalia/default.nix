{...}: let
  sources = {
    official = {
      name = "Official Noctalia Plugins";
      url = "https://github.com/noctalia-dev/noctalia-plugins";
    };
  };

  sourceList = builtins.attrValues (builtins.mapAttrs (key: src: {
      enabled = true;
      inherit (src) name url;
    })
    sources);
in {
  xdg.configFile."noctalia/colorschemes/One/One.json".source = ./colorschemes/One/One.json;

  programs.noctalia-shell = {
    enable = true;

    plugins = {
      sources = sourceList;
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

    settings = ./settings.json;
  };
}
