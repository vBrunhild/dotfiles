{config, pkgs, inputs, ...}: let
  copilot-cli = (pkgs.github-copilot-cli.overrideAttrs (oldAttrs: {
    postInstall = "";
  }));
in {
  environment.systemPackages = [
    copilot-cli
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.bat
    pkgs.bottom
    pkgs.cloudflared
    pkgs.curl
    pkgs.direnv
    pkgs.docker
    pkgs.docker-compose
    pkgs.dust
    pkgs.eza
    pkgs.fd
    pkgs.ffmpeg
    pkgs.git-credential-manager
    pkgs.gitFull
    pkgs.jujutsu
    pkgs.just
    pkgs.nh
    pkgs.nushell
    pkgs.nvd
    pkgs.opentofu
    pkgs.ouch
    pkgs.pandoc
    pkgs.ripgrep
    pkgs.rsync
    pkgs.sd
    pkgs.tabiew
    pkgs.tealdeer
    pkgs.tinymist
    pkgs.typst
    pkgs.uutils-coreutils-noprefix
    pkgs.uv
    pkgs.zellij
    pkgs.zoxide
  ];

  services.openssh.enable = true;

  programs.bat.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;

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

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host *
        # Identity
        IdentityFile ~/.ssh/id_ed25519
        AddKeysToAgent yes

        # Security
        HashKnownHosts yes

        # Connection
        ServerAliveCountMax 5
        ServerAliveInterval 60
        TCPKeepAlive yes

        # Control
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%h:%p
    '';
  };
}
