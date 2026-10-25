{config, ...}: {
  flake.modules.nixos.base = {
    imports = with config.flake.modules.nixos; [
      agenix
      boot
      console
      cursor
      fonts
      gtk
      home-manager
      locale
      nix
      qt
      users
    ];
  };
}
