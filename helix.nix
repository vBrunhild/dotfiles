{ pkgs, ... }:

let
  tomlFormat = pkgs.formats.toml { };

  config = {
    theme = "zed_onedark";
    editor = {
      rulers = [ 120 ];
      auto-completion = true;
      completion-trigger-len = 2;
      idle-timeout = 250;
      cursorline = true;
      color-modes = true;
      true-color = true;

      indent-guides = {
        render = true;
        character = "|";
        skip-levels = 0;
      };

      lsp = {
        display-messages = true;
        display-inlay-hints = true;
      };
    };
  };

  languages = {
    language = [
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = "nixfmt";
        };
        language-server = [ "nil" ];
      }
      {
        name = "rust";
        language-servers = [ "rust-analyzer" ];
      }
    ];

    language-server = {
      rust-analyzer = {
        command = "rust-analyzer";
        config = {
          rust-analyzer = {
            config.check = {
              command = "clippy";
              features = "all";
            };

            inlayHints = {
              bindingModeHints.enable = false;
              chainingHints.enable = true;
              closingBracesHints.enable = true;
              closureReturnTypeHints.enable = true;
              discriminantHints.enable = true;
              lifetimeElisionHints.enable = true;
              parameterHints.enable = true;
              reborrowHints.enable = true;
              renderColons = true;
              typeHints.enable = true;
              typeHints.hideClosureInitialization = false;
              typeHints.hideNamedConstructor = false;
            };
          };
        };
      };

      nil = {
        command = "nil";
        config.nil.formatting.command = [ "nixfmt" ];
      };
    };
  };

in
{
  environment.etc = {
    "helix/config.toml".source = tomlFormat.generate "config.toml" config;
    "helix/languages.toml".source = tomlFormat.generate "languages.toml" languages;
  };
}
