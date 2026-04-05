{...}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./packages
  ];

  home-manager.users.brunhild.imports = [./theme.nix];
}
