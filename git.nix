{ ... }:

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
      branch.autosetupmerge = "true";
      push.default = "current";
      merge.stat = "true";
      core.whitespace = "fix,trailing-space";
      pull.ff = "only";
    };
  };
}
