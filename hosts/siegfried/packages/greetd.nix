{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command =
          # bash
          ''
            ${pkgs.tuigreet}/bin/tuigreet \
              --time \
              --remember \
              --cmd niri-session
          '';
      };
    };
  };
}
