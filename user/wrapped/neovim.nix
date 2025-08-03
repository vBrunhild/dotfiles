{pkgs, ...}: let
  inherit (builtins) attrValues;

  lspPackages = [
    pkgs.alejandra
    pkgs.dprint
    pkgs.dprint-plugins.dprint-plugin-json
    pkgs.lua-language-server
    pkgs.nil
    pkgs.nixd
    pkgs.taplo
  ];

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    customRC = ''
      source ~/.config/nvim/init.lua
    '';

    plugins =
      (attrValues {
        inherit (pkgs.vimPlugins)
          blink-cmp
          conform-nvim
          friendly-snippets
          guess-indent-nvim
          markview-nvim
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
          nvim-lspconfig
          nvim-nio
          nvim-osc52
          onedarkpro-nvim
          typst-preview-nvim
          zellij-nav-nvim
        ;
      })
      ++ [
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
  };
in
  pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths =
      [
        (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig)
      ]
      ++ lspPackages;
  }
