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
      openssl
      git
      git-credential-manager
      curl
      direnv
      fish
      zellij
      helix
      docker
      nil
      nixfmt-rfc-style
      gitui
      yazi
      starship
      zoxide
      uutils-coreutils-noprefix
      taplo

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
