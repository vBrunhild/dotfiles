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
        onedark-nvim
	telescope-nvim
	undotree
	gitsigns-nvim
	lualine-nvim
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
	cmp-nvim-lsp
	cmp-buffer
	cmp-path
      ;
    }) ++ [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [ (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig) ];
  }
