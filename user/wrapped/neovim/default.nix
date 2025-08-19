{pkgs, ...}: let
  inherit (builtins) attrValues;

  plugins =
    (attrValues {
      inherit (pkgs.vimPlugins)
        blink-cmp
        conform-nvim
        friendly-snippets
        lze
        mini-bufremove
        mini-clue
        mini-comment
        mini-diff
        mini-extra
        mini-files
        mini-git
        mini-hipatterns
        mini-icons
        mini-indentscope
        mini-operators
        mini-pairs
        mini-pick
        mini-snippets
        mini-splitjoin
        mini-statusline
        mini-surround
        mini-trailspace
        nvim-dap
        nvim-dap-view
        nvim-lint
        onedarkpro-nvim
        snacks-nvim
        typst-preview-nvim
        zellij-nav-nvim
      ;
    })
    ++ [pkgs.vimPlugins.nvim-treesitter.withAllGrammars];

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customLuaRC = builtins.readFile ./init.lua;
    plugins = plugins;
  };

  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
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
      pkgs.lua-language-server
      pkgs.nil
      pkgs.nixd
      pkgs.taplo
    ];
  }
