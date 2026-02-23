{inputs, ...}: {
  home-manager.users.brunhild = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = ./noctalia.nix;
  };
}
