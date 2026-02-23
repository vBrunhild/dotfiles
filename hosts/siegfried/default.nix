{...}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./home-manager
    ./packages.nix
    ./services.nix
  ];
}
