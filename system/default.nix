{ ... }:

{
  imports = [
    # ./boot
    ./disks
    ./fonts
    ./users
    ./nix
  ];

  system.stateVersion = "24.11";
}
