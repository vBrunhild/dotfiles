{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      user = {
        email = "brunomoretti100@gmail.com";
        name = "vBrunhild";
      };
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credentialStore = "cache";
      };
      branch.autosetupmerge = "true";
      push.default = "current";
      merge.stat = "true";
      core.whitespace = "fix,trailing-space";
      pull.ff = "only";
    };
  };
}
