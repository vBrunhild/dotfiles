{inputs, ...}: {
  imports = [inputs.danksearch.homeModules.dsearch];
  programs.dsearch.enable = true;
}
