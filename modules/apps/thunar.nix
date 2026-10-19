{
  flake.modules.nixos.thunar = {
    programs.thunar.enable = true;
    services.tumbler.enable = true;
  };
}
