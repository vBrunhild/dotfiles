{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  imports = [
    ./git.nix
    ./ssh.nix
  ];

  home-manager.users.brunhild.imports = [
    ./nushell
    ./zellij
  ];

  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
    inputs.determinate.packages.${system}.default
    inputs.neovim.packages.${system}.default
    inputs.sem.packages.${system}.default
    pkgs.atlas
    pkgs.bat
    pkgs.boring
    pkgs.bottom
    pkgs.cloudflared
    pkgs.curl
    pkgs.deploy-rs
    pkgs.direnv
    pkgs.docker-compose
    pkgs.dust
    pkgs.eza
    pkgs.ffmpeg
    pkgs.gh
    pkgs.git-credential-manager
    pkgs.gitFull
    pkgs.jq
    pkgs.jujutsu
    pkgs.just
    pkgs.mutagen
    pkgs.nh
    pkgs.nushell
    pkgs.opentofu
    pkgs.ouch-rar
    pkgs.pandoc
    pkgs.rclone
    pkgs.ripgrep
    pkgs.rsync
    pkgs.sd
    pkgs.tabiew
    pkgs.tealdeer
    pkgs.tuicr
    pkgs.uutils-coreutils-noprefix
    pkgs.zerotierone
    pkgs.zoxide
  ];

  services.openssh.enable = true;

  programs = {
    bat.enable = true;
    direnv.enable = true;
    zoxide.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.nix-ld = {
    enable = true;
    libraries = [
      pkgs.stdenv.cc.cc.lib
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/home/brunhild/dotfiles";
  };
}
