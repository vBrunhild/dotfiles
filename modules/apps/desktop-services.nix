{
  flake.modules.nixos.desktop-services = {
    services = {
      devmon.enable = true;
      gnome.gcr-ssh-agent.enable = false;
      gnome.gnome-keyring.enable = true;
      power-profiles-daemon.enable = true;
      pulseaudio.enable = false;
      upower.enable = true;
    };
  };
}
