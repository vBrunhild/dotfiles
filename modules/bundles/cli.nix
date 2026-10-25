{config, ...}: {
  flake.modules.nixos.cli = {
    imports = with config.flake.modules.nixos; [
      atlas
      bat
      bitbucket-cli
      boring
      bottom
      claude
      cli-tools
      delta
      dev-tools
      direnv
      git
      gnupg
      jujutsu
      neovim
      nh
      nix-ld
      nushell
      openssh
      playwright-cli
      podman
      ripgrep
      sem
      ssh
      tuicr
      usql
      zellij
      zoxide
    ];
  };
}
