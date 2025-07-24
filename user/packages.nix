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
      docker
      gitui
      yazi
      starship
      zoxide
      uutils-coreutils-noprefix
      ripgrep
      fd
      wezterm
      zellij
    ;
  } ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
