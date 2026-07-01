{
  pkgs,
  inputs,
  flake,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;

  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
  path-server = flake.packages.${system}.path-server;

  neovim-wrapped = pkgs.wrapNeovimUnstable neovim-nightly {
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    luaRcContent = builtins.readFile ./init.lua;
    plugins = [
      pkgs.vimPlugins.conform-nvim
      pkgs.vimPlugins.live-command-nvim
      pkgs.vimPlugins.lze
      pkgs.vimPlugins.mini-ai
      pkgs.vimPlugins.mini-align
      pkgs.vimPlugins.mini-bufremove
      pkgs.vimPlugins.mini-clue
      pkgs.vimPlugins.mini-cmdline
      pkgs.vimPlugins.mini-comment
      pkgs.vimPlugins.mini-completion
      pkgs.vimPlugins.mini-diff
      pkgs.vimPlugins.mini-extra
      pkgs.vimPlugins.mini-files
      pkgs.vimPlugins.mini-git
      pkgs.vimPlugins.mini-hipatterns
      pkgs.vimPlugins.mini-icons
      pkgs.vimPlugins.mini-indentscope
      pkgs.vimPlugins.mini-input
      pkgs.vimPlugins.mini-keymap
      pkgs.vimPlugins.mini-notify
      pkgs.vimPlugins.mini-operators
      pkgs.vimPlugins.mini-pick
      pkgs.vimPlugins.mini-snippets
      pkgs.vimPlugins.mini-splitjoin
      pkgs.vimPlugins.mini-statusline
      pkgs.vimPlugins.mini-surround
      pkgs.vimPlugins.mini-trailspace
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.onedarkpro-nvim
      pkgs.vimPlugins.quicker-nvim
      pkgs.vimPlugins.typst-preview-nvim
    ];
  };
in
  pkgs.symlinkJoin {
    inherit (neovim-nightly) version meta;
    pname = "neovim-wrapped";
    paths = [
      neovim-wrapped
      path-server
      pkgs.alejandra
      pkgs.docker-language-server
      pkgs.dprint
      pkgs.dprint-plugins.dprint-plugin-json
      pkgs.dprint-plugins.dprint-plugin-markdown
      pkgs.dprint-plugins.dprint-plugin-typescript
      pkgs.harper
      pkgs.just-lsp
      pkgs.lua-language-server
      pkgs.markdown-oxide
      pkgs.nil
      pkgs.nixd
      pkgs.ripgrep
      pkgs.taplo
      pkgs.vscode-langservers-extracted
    ];
  }
