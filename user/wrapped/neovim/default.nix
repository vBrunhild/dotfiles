{pkgs, ...}: let
  inherit (builtins) attrValues;

  plugins =
    (attrValues {
      inherit
        (pkgs.vimPlugins)
        blink-cmp
        conform-nvim
        friendly-snippets
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
        nvim-colorizer-lua
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

  pluginsLuaModule = let
    lineFor = plugin: ''P["${plugin.pname}"] = "${plugin}"'';
  in
    pkgs.vimUtils.buildVimPlugin {
      pname = "nixplugins";
      version = "1.0.0";
      src = pkgs.writeTextDir "lua/nixplugins.lua" ''
        local P = {}
        ${builtins.concatStringsSep "\n" (builtins.map lineFor plugins)}
        return P
      '';
    };

  # nix build --impure --show-trace --expr 'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./user/wrapped/neovim/default.nix {}'

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customLuaRC = builtins.readFile ./init.lua;
    plugins = [pkgs.vimPlugins.lazy-nvim pluginsLuaModule] ++ plugins;
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
      pkgs.lua-language-server
      pkgs.nil
      pkgs.nixd
      pkgs.taplo
    ];
  }
