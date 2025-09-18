{inputs, pkgs, ...}: let
  nvim-treesitter-parsers = pkgs.symlinkJoin {
    name = "nvim-treesitter-parsers";
    paths = [
      pkgs.vimPlugins.nvim-treesitter-parsers.bash
      pkgs.vimPlugins.nvim-treesitter-parsers.c
      pkgs.vimPlugins.nvim-treesitter-parsers.c_sharp
      pkgs.vimPlugins.nvim-treesitter-parsers.cmake
      pkgs.vimPlugins.nvim-treesitter-parsers.cpp
      pkgs.vimPlugins.nvim-treesitter-parsers.css
      pkgs.vimPlugins.nvim-treesitter-parsers.csv
      pkgs.vimPlugins.nvim-treesitter-parsers.dockerfile
      pkgs.vimPlugins.nvim-treesitter-parsers.fish
      pkgs.vimPlugins.nvim-treesitter-parsers.git_config
      pkgs.vimPlugins.nvim-treesitter-parsers.git_rebase
      pkgs.vimPlugins.nvim-treesitter-parsers.gitattributes
      pkgs.vimPlugins.nvim-treesitter-parsers.gitcommit
      pkgs.vimPlugins.nvim-treesitter-parsers.gitignore
      pkgs.vimPlugins.nvim-treesitter-parsers.go
      pkgs.vimPlugins.nvim-treesitter-parsers.goctl
      pkgs.vimPlugins.nvim-treesitter-parsers.gomod
      pkgs.vimPlugins.nvim-treesitter-parsers.gosum
      pkgs.vimPlugins.nvim-treesitter-parsers.groovy
      pkgs.vimPlugins.nvim-treesitter-parsers.haskell
      pkgs.vimPlugins.nvim-treesitter-parsers.html
      pkgs.vimPlugins.nvim-treesitter-parsers.java
      pkgs.vimPlugins.nvim-treesitter-parsers.javascript
      pkgs.vimPlugins.nvim-treesitter-parsers.jsdoc
      pkgs.vimPlugins.nvim-treesitter-parsers.json
      pkgs.vimPlugins.nvim-treesitter-parsers.json5
      pkgs.vimPlugins.nvim-treesitter-parsers.jsonc
      pkgs.vimPlugins.nvim-treesitter-parsers.kdl
      pkgs.vimPlugins.nvim-treesitter-parsers.lua
      pkgs.vimPlugins.nvim-treesitter-parsers.luadoc
      pkgs.vimPlugins.nvim-treesitter-parsers.make
      pkgs.vimPlugins.nvim-treesitter-parsers.markdown
      pkgs.vimPlugins.nvim-treesitter-parsers.markdown_inline
      pkgs.vimPlugins.nvim-treesitter-parsers.nix
      pkgs.vimPlugins.nvim-treesitter-parsers.nu
      pkgs.vimPlugins.nvim-treesitter-parsers.ocaml
      pkgs.vimPlugins.nvim-treesitter-parsers.python
      pkgs.vimPlugins.nvim-treesitter-parsers.regex
      pkgs.vimPlugins.nvim-treesitter-parsers.rust
      pkgs.vimPlugins.nvim-treesitter-parsers.scheme
      pkgs.vimPlugins.nvim-treesitter-parsers.toml
      pkgs.vimPlugins.nvim-treesitter-parsers.typescript
      pkgs.vimPlugins.nvim-treesitter-parsers.typst
      pkgs.vimPlugins.nvim-treesitter-parsers.vim
      pkgs.vimPlugins.nvim-treesitter-parsers.vimdoc
      pkgs.vimPlugins.nvim-treesitter-parsers.xml
      pkgs.vimPlugins.nvim-treesitter-parsers.yaml
      pkgs.vimPlugins.nvim-treesitter-parsers.zig
    ];
  };

  plugins = [
    nvim-treesitter-parsers
    pkgs.vimPlugins.blink-cmp
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.friendly-snippets
    pkgs.vimPlugins.lze
    pkgs.vimPlugins.mini-align
    pkgs.vimPlugins.mini-bufremove
    pkgs.vimPlugins.mini-clue
    pkgs.vimPlugins.mini-colors
    pkgs.vimPlugins.mini-comment
    pkgs.vimPlugins.mini-diff
    pkgs.vimPlugins.mini-extra
    pkgs.vimPlugins.mini-files
    pkgs.vimPlugins.mini-git
    pkgs.vimPlugins.mini-hipatterns
    pkgs.vimPlugins.mini-icons
    pkgs.vimPlugins.mini-indentscope
    pkgs.vimPlugins.mini-operators
    pkgs.vimPlugins.mini-pick
    pkgs.vimPlugins.mini-snippets
    pkgs.vimPlugins.mini-splitjoin
    pkgs.vimPlugins.mini-statusline
    pkgs.vimPlugins.mini-surround
    pkgs.vimPlugins.mini-trailspace
    pkgs.vimPlugins.nvim-lint
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.onedarkpro-nvim
    pkgs.vimPlugins.typst-preview-nvim
  ];

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customLuaRC = builtins.readFile ./init.lua;
    inherit plugins;
  };

  neovim = pkgs.wrapNeovimUnstable inputs.neovim-nightly-overlay.packages.${pkgs.system}.default neovimConfig;
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [
      neovim
      pkgs.alejandra
      pkgs.dprint
      pkgs.dprint-plugins.dprint-plugin-json
      pkgs.dprint-plugins.dprint-plugin-markdown
      pkgs.dprint-plugins.dprint-plugin-typescript
      pkgs.harper
      pkgs.lua-language-server
      pkgs.markdown-oxide
      pkgs.nil
      pkgs.nixd
      pkgs.taplo
      pkgs.vscode-langservers-extracted
    ];
  }
