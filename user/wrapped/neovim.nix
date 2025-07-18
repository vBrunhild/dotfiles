{ pkgs, ... }:
let
  inherit (builtins) attrValues;

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
      pkgs.gopls
      pkgs.rust-analyzer
      pkgs.lua-language-server
      pkgs.nil
      pkgs.nixd
      pkgs.basedpyright
      pkgs.taplo
    ];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [ (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig) ];
  }

