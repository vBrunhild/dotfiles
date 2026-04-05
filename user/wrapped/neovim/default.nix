{
  inputs,
  pkgs,
  lib,
  ...
}: let
  mkGrammar = {
    language,
    version,
    hash,
  }:
    pkgs.tree-sitter.buildGrammar {
      inherit language version;
      src = pkgs.fetchFromGitHub {
        owner = "tree-sitter-grammars";
        repo = "tree-sitter-${language}";
        rev = "v${version}";
        inherit hash;
      };
    };

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths =
      map
      (grammar: let
        grammarName = lib.pipe grammar.pname [
          (lib.removePrefix "tree-sitter-")
          (builtins.replaceStrings ["-"] ["_"])
        ];
      in
        pkgs.runCommand "${grammar.name}-parser" {} ''
          mkdir -p $out/parser
          ln -s ${grammar}/parser \
            $out/parser/${grammarName}.so
        '')
      [
        pkgs.tree-sitter-grammars.tree-sitter-bash
        pkgs.tree-sitter-grammars.tree-sitter-c
        pkgs.tree-sitter-grammars.tree-sitter-c-sharp
        pkgs.tree-sitter-grammars.tree-sitter-cmake
        pkgs.tree-sitter-grammars.tree-sitter-cpp
        pkgs.tree-sitter-grammars.tree-sitter-css
        pkgs.tree-sitter-grammars.tree-sitter-csv
        pkgs.tree-sitter-grammars.tree-sitter-diff
        pkgs.tree-sitter-grammars.tree-sitter-dockerfile
        pkgs.tree-sitter-grammars.tree-sitter-elixir
        pkgs.tree-sitter-grammars.tree-sitter-git-config
        pkgs.tree-sitter-grammars.tree-sitter-git-rebase
        pkgs.tree-sitter-grammars.tree-sitter-gitattributes
        pkgs.tree-sitter-grammars.tree-sitter-gitcommit
        pkgs.tree-sitter-grammars.tree-sitter-gitignore
        pkgs.tree-sitter-grammars.tree-sitter-go
        pkgs.tree-sitter-grammars.tree-sitter-gomod
        pkgs.tree-sitter-grammars.tree-sitter-groovy
        pkgs.tree-sitter-grammars.tree-sitter-haskell
        pkgs.tree-sitter-grammars.tree-sitter-html
        pkgs.tree-sitter-grammars.tree-sitter-ini
        pkgs.tree-sitter-grammars.tree-sitter-java
        pkgs.tree-sitter-grammars.tree-sitter-javascript
        pkgs.tree-sitter-grammars.tree-sitter-jjdescription
        pkgs.tree-sitter-grammars.tree-sitter-jq
        pkgs.tree-sitter-grammars.tree-sitter-jsdoc
        pkgs.tree-sitter-grammars.tree-sitter-json
        pkgs.tree-sitter-grammars.tree-sitter-json5
        pkgs.tree-sitter-grammars.tree-sitter-just
        pkgs.tree-sitter-grammars.tree-sitter-kdl
        pkgs.tree-sitter-grammars.tree-sitter-lua
        pkgs.tree-sitter-grammars.tree-sitter-make
        pkgs.tree-sitter-grammars.tree-sitter-markdown
        pkgs.tree-sitter-grammars.tree-sitter-markdown-inline
        pkgs.tree-sitter-grammars.tree-sitter-mermaid
        pkgs.tree-sitter-grammars.tree-sitter-nginx
        pkgs.tree-sitter-grammars.tree-sitter-nix
        pkgs.tree-sitter-grammars.tree-sitter-nu
        pkgs.tree-sitter-grammars.tree-sitter-ocaml
        pkgs.tree-sitter-grammars.tree-sitter-php
        pkgs.tree-sitter-grammars.tree-sitter-php-only
        pkgs.tree-sitter-grammars.tree-sitter-phpdoc
        pkgs.tree-sitter-grammars.tree-sitter-python
        pkgs.tree-sitter-grammars.tree-sitter-regex
        pkgs.tree-sitter-grammars.tree-sitter-rust
        pkgs.tree-sitter-grammars.tree-sitter-scheme
        pkgs.tree-sitter-grammars.tree-sitter-sql
        pkgs.tree-sitter-grammars.tree-sitter-toml
        pkgs.tree-sitter-grammars.tree-sitter-tsx
        pkgs.tree-sitter-grammars.tree-sitter-typescript
        pkgs.tree-sitter-grammars.tree-sitter-typst
        pkgs.tree-sitter-grammars.tree-sitter-vim
        pkgs.tree-sitter-grammars.tree-sitter-xml
        pkgs.tree-sitter-grammars.tree-sitter-yaml
        pkgs.tree-sitter-grammars.tree-sitter-zig

        (mkGrammar {
          language = "luadoc";
          version = "1.1.0";
          hash = "sha256-8ZHgMoeirXlwUlfrphKNFWVX/k2+uEIYCh3MJ9r7YOk=";
        })
      ];
  };

  treesitter-queries = pkgs.symlinkJoin {
    name = "treesitter-queries";
    paths = [
      (pkgs.linkFarm "custom-ts-queries" [
        {
          name = "queries";
          path = ./queries;
        }
      ])
    ];
  };

  neovim-nightly = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  neovim-wrapped = pkgs.wrapNeovimUnstable neovim-nightly {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    luaRcContent = builtins.readFile ./init.lua;
    plugins = [
      treesitter-queries
      treesitter-parsers

      pkgs.vimPlugins.conform-nvim
      pkgs.vimPlugins.lze
      pkgs.vimPlugins.markview-nvim
      pkgs.vimPlugins.mini-align
      pkgs.vimPlugins.mini-bufremove
      pkgs.vimPlugins.mini-clue
      pkgs.vimPlugins.mini-cmdline
      pkgs.vimPlugins.mini-comment
      pkgs.vimPlugins.mini-completion
      pkgs.vimPlugins.mini-diff
      pkgs.vimPlugins.mini-extra
      pkgs.vimPlugins.mini-files
      pkgs.vimPlugins.mini-git
      pkgs.vimPlugins.mini-hipatterns
      pkgs.vimPlugins.mini-icons
      pkgs.vimPlugins.mini-indentscope
      pkgs.vimPlugins.mini-keymap
      pkgs.vimPlugins.mini-notify
      pkgs.vimPlugins.mini-operators
      pkgs.vimPlugins.mini-pick
      pkgs.vimPlugins.mini-snippets
      pkgs.vimPlugins.mini-splitjoin
      pkgs.vimPlugins.mini-statusline
      pkgs.vimPlugins.mini-surround
      pkgs.vimPlugins.mini-trailspace
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.onedarkpro-nvim
      pkgs.vimPlugins.typst-preview-nvim
    ];
  };
in
  pkgs.symlinkJoin {
    pname = "neovim-wrapped";
    version = neovim-nightly.version;
    meta.mainProgram = "nvim";
    paths = [
      neovim-wrapped
      pkgs.alejandra
      pkgs.docker-language-server
      pkgs.dprint
      pkgs.dprint-plugins.dprint-plugin-json
      pkgs.dprint-plugins.dprint-plugin-markdown
      pkgs.dprint-plugins.dprint-plugin-typescript
      pkgs.harper
      pkgs.just-lsp
      pkgs.lua-language-server
      pkgs.markdown-oxide
      pkgs.nil
      pkgs.nixd
      pkgs.just-lsp
      pkgs.pyrefly
      pkgs.ruff
      pkgs.taplo
      pkgs.tofu-ls
      pkgs.vscode-langservers-extracted
    ];
  }
