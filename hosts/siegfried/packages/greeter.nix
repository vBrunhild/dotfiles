{inputs, quickshell, ...}: {
  imports = [inputs.dms.nixosModules.greeter];

  programs.dank-material-shell.greeter = {
    configHome = "/home/brunhild";
    compositor.name = "niri";
    quickshell.package = quickshell;
  };
}
