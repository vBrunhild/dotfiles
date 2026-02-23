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

      url = {
        label-letters = "sadfjlewcmpgh";
        launch = "xdg-open \${url}";
        osc8-underline = "url-mode";
      };

      colors = {
        foreground="CDD4E1";
        background="1E2127";
        regular0="1E2127";
        regular1="E06C75";
        regular2="61AFEF";
        regular3="CCC67F";
        regular4="98C379";
        regular5="C678DD";
        regular6="61AFEF";
        regular7="CDD4E1";
        bright0="282C34";
        bright1="FF949D";
        bright2="AFF2C0";
        bright3="F2EDAF";
        bright4="C3E9A8";
        bright5="EAA4FF";
        bright6="81C6FF";
        bright7="FFFFFF";
        selection-foreground="1E2127";
        selection-background="CDD4E1";
        cursor="1E2127 98C379";
      };
    };
  };
}
