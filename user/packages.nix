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
      gitui
      yazi
      starship
      zoxide
      uutils-coreutils-noprefix
      ripgrep
      fd
    ;
  } ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
