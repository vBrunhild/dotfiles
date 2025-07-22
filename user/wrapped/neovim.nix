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
        lualine-nvim
        nvim-osc52
        indent-blankline-nvim-lua
        nvim-autopairs
        comment-nvim
        nvim-colorizer-lua
        lsp_lines-nvim
        trouble-nvim
        nvim-lspconfig
        luasnip
        friendly-snippets
        blink-cmp
        conform-nvim
        guess-indent-nvim
        which-key-nvim
        mini-icons
        nvim-web-devicons
        nvim-nio
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
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

