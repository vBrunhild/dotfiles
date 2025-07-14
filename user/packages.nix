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
      typst
      tinymist

      # rust tools
      rustup
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
    ;
  } ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
