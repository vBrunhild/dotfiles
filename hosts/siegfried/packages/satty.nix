{
  programs.satty = {
    enable = true;
    settings = {
      general = {
        fullscreen = false;
        copy-command = "wl-copy";
        output-filename = "/tmp/screenshot-%Y-%m-%dT%H-%M-%S.png";
        disable-notifications = true;
      };
    };
  };
}
