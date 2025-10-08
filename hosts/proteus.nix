{
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    {
      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = "brunhild";
      };
    }
  ];
}
