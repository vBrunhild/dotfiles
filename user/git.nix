{pkgs, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      user = {
        email = "brunomoretti100@gmail.com";
        name = "vBrunhild";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credentialStore = "cache";
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
}
