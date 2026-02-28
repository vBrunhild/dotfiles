{inputs, ...}: {
  home-manager.users.brunhild = {
    imports = [
      ./flameshot.nix
      ./noctalia.nix
      inputs.noctalia.homeModules.default
    ];
  };
}
