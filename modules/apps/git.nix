{config, ...}: let
  inherit (config) meta;
  inherit (config.flake) wrappers;
in {
  flake.wrappers.git = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.wrapperModules.git];

    package = pkgs.gitFull;
    runtimePkgs = [pkgs.git-lfs];

    # keep ~/.gitconfig writable for `git config --global`
    env.GIT_CONFIG_GLOBAL = lib.mkForce null;
    env.GIT_CONFIG_SYSTEM = config.configFile.path;

    settings = {
      user = {
        inherit (meta) email;
        name = meta.gitName;
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credentialStore = "cache";
      };
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        process = "git-lfs filter-process";
        required = true;
        smudge = "git-lfs smudge -- %f";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      branch.autosetupmerge = "true";
      push.default = "current";
      merge.stat = "true";
      core.whitespace = "fix,trailing-space";
      pull.ff = "only";
    };
  };

  flake.modules.nixos.git = {pkgs, ...}: {
    imports = [wrappers.git.install];
    wrappers.git.enable = true;

    environment.systemPackages = [
      pkgs.git-credential-manager
      pkgs.git-lfs
    ];
  };
}
