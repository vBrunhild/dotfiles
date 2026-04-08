{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
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
    pkgs.fzf
    pkgs.git-credential-manager
    pkgs.gitFull
    pkgs.github-copilot-cli
    pkgs.jq
    pkgs.jujutsu
    pkgs.just
    pkgs.nh
    pkgs.nushell
    pkgs.nvd
    pkgs.opentofu
    pkgs.ouch
    pkgs.pandoc
    pkgs.resvg
    pkgs.ripgrep
    pkgs.rsync
    pkgs.sd
    pkgs.tabiew
    pkgs.tealdeer
    pkgs.terragrunt
    pkgs.tinymist
    pkgs.typst
    pkgs.uutils-coreutils-noprefix
    pkgs.uv
    pkgs.zellij
    pkgs.zerotierone
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
