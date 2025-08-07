{pkgs, ...}: let
  inherit (builtins) attrValues;
  # lua = pkgs.lua5_1;
  #
  # init = pkgs.stdenv.mkDerivation {
  #   name = "nvim-compiled-init";
  #   src = ../../config/nvim;
  #
  #   nativeBuildInputs = [lua];
  #
  #   installPhase = ''
  #     mkdir -p $out/nvim
  #     luac -o $out/nvim/init.lc init.lua
  #   '';
  # };

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customRC = ''
      source ~/.config/nvim/init.lua
    '';

    plugins =
      (attrValues {
        inherit(pkgs.vimPlugins)
          blink-cmp
          conform-nvim
          friendly-snippets
          lazy-nvim
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
          mini-keymap
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
          nvim-nio
          nvim-osc52
          onedarkpro-nvim
          snacks-nvim
          typst-preview-nvim
          zellij-nav-nvim
        ;
      })
      ++ [pkgs.vimPlugins.nvim-treesitter.withAllGrammars];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths =
      [(pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig)]
      ++ [
        pkgs.alejandra
        pkgs.dprint
        pkgs.dprint-plugins.dprint-plugin-json
        pkgs.lua-language-server
        pkgs.nil
        pkgs.nixd
        pkgs.taplo
      ];
  }g
