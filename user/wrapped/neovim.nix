{ pkgs, ... }:
let
  inherit (builtins) attrValues;

  lspPackages = [
    pkgs.gopls
    pkgs.golangci-lint
    pkgs.golangci-lint-langserver
    pkgs.go-tools
    pkgs.rust-analyzer
    pkgs.lua-language-server
    pkgs.nil
    pkgs.nixd
    pkgs.basedpyright
    pkgs.taplo
    pkgs.dprint
    pkgs.dprint-plugins.dprint-plugin-json
  ];

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customRC = ''
      :luafile ~/.config/nvim/init.lua
    '';

    plugins = (attrValues {
      inherit (pkgs.vimPlugins)
        onedarkpro-nvim
        telescope-nvim
        undotree
        gitsigns-nvim
        nvim-osc52
        nvim-colorizer-lua
        lsp_lines-nvim
        nvim-lspconfig
        luasnip
        friendly-snippets
        blink-cmp
        conform-nvim
        guess-indent-nvim
        nvim-nio
        nvim-dap
        nvim-dap-view
        zellij-nav-nvim
        obsidian-nvim
        mini-icons
        mini-comment
        mini-keymap
        mini-pairs
        mini-clue
        mini-files
        mini-git
        mini-diff
        mini-statusline
        mini-trailspace
        mini-indentscope
        mini-splitjoin
        mini-surround
      ;
    }) ++ [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [
      (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig)
    ] ++ lspPackages;
  }

