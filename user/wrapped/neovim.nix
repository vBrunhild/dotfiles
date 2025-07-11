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
      	telescope-nvim
        harpoon
      	
      ;
    }) ++ [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [ (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig) ];
  }
