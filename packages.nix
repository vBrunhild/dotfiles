{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
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
    unstable.rustup
  ];

  programs.fish.enable = true;
}
