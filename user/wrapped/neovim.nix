{ pkgs, ... }:
let
  inherit (builtins) attrValues;

  lspPackages = [
    pkgs.gopls
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
        harpoon
        nvim-lspconfig
        nvim-cmp
        luasnip
        friendly-snippets
        blink-cmp
        conform-nvim
        guess-indent-nvim
        which-key-nvim
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

