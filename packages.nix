{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
{
  environment.systemPackages = [
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
    unstable.rustup
  ];

  programs.fish.enable = true;
}
