{...}: {
  imports = [
    ./boot
    ./fonts
    ./users
    ./nix
  ];

  system.stateVersion = "24.11";
}
