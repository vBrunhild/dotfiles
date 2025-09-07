{...}: {
  imports = [
    ./boot
    ./fonts
    ./users
    ./nix
  ];

  system.stateVersion = "25.05";
  time.timeZone = "America/Campo_Grande";
}
