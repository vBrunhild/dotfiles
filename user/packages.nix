{ pkgs, inputs, ... }:
let
  inherit (builtins) attrValues;
in {
  environment.systemPackages = attrValues {
    inherit (pkgs)
      nh
      stow
      gcc
      clang
      git
      git-credential-manager
      curl
      direnv
      fish
      zellij
      docker
      nil
      nixfmt-rfc-style
      nixd
      gitui
      yazi
      starship
      zoxide
      uutils-coreutils-noprefix
      taplo
      ripgrep
      fd

      # typst tools
      typst
      tinymist

      # rust tools
      cargo
      rust-analyzer
      bacon
      clippy

      # python tools
      python312
      python313
      uv
      ruff
      basedpyright

      # go tools
      go
      gopls
    ;
  } ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
