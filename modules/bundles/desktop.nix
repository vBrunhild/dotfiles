{config, ...}: {
  flake.modules.nixos.desktop = {
    imports = with config.flake.modules.nixos; [
      avahi
      bluetooth
      desktop-services
      foot
      gui-apps
      niri
      noctalia
      pipewire
      printing
      sioyek
      spotify
      steam
      thunar
      xserver
    ];
  };
}
