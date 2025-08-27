{...}: {
  imports = [
    ./boot
    ./fonts
    ./users
    ./nix
  ];

  system.stateVersion = "25.05";
}
