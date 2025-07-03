{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.stow
    pkgs.gcc
    pkgs.clang
    pkgs.git
    pkgs.git-credential-manager
    pkgs.curl
    pkgs.uv
    pkgs.fish
    pkgs.zellij
    pkgs.helix
    pkgs.docker
    pkgs.nil
    pkgs.nixfmt-rfc-style
    pkgs.gitui
    pkgs.yazi
    pkgs.starship
    pkgs.zoxide
    pkgs.uutils-coreutils-noprefix
    pkgs.taplo
    pkgs.rustup
    pkgs.cargo
    pkgs.rust-analyzer
    pkgs.bacon
    pkgs.clippy
  ];

  programs.fish.enable = true;
}
