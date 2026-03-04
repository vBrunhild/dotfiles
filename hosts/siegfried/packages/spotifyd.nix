{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pulseaudio";
        bitrate = 320;
        device_type = "computer";
        volume_normalisation = true;
        zeroconf_port = 57621;
      };
    };
  };
}
