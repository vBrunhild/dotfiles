{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.flameshot
    pkgs.google-chrome
    pkgs.grim
    pkgs.obs-studio
    pkgs.spotify-player
    pkgs.udevil
    pkgs.vlc
    pkgs.wl-clipboard
    pkgs.xwayland-satellite
  ];

  programs = {
    niri.enable = true;
    steam.enable = true;
    thunar.enable = true;
  };

  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "monospace:size=9";
        pad = "10x10";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3.0;
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        foreground = "b6bdca";
        background = "282c34";

        regular0 = "282c34";
        regular1 = "e06c75";
        regular2 = "98c379";
        regular3 = "e5c07b";
        regular4 = "61afef";
        regular5 = "c678dd";
        regular6 = "56b6c2";
        regular7 = "b6bdca";

        bright0 = "565c64";
        bright1 = "e06c75";
        bright2 = "98c379";
        bright3 = "e5c07b";
        bright4 = "61afef";
        bright5 = "c678dd";
        bright6 = "56b6c2";
        bright7 = "fffefe";

        selection-foreground = "282c34";
        selection-background = "b6bdca";
        cursor = "1e2127 98c379";
      };
    };
  };
}
