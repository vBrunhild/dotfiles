{ pkgs, ... }:
let
  plugins = [
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
    pkgs.vimPlugins.nvim-dap
    pkgs.vimPlugins.nvim-dap-view
    pkgs.vimPlugins.nvim-lint
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    pkgs.vimPlugins.onedarkpro-nvim
    pkgs.vimPlugins.typst-preview-nvim
  ];

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
