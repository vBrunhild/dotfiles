{pkgs, ...}: {
  services.desktopManager.plasma6.enable = true;
  services.devmon.enable = true;
  services.displayManager.sddm.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  services.pulseaudio.enable = false;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "br";
      variant = "";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.hplipWithPlugin];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # media-session.enable = true;
  };
}
