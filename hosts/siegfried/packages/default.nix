{
  pkgs,
  ...
}: {
  imports = [
    ./avahi.nix
    ./foot.nix
    ./noctalia
    ./pipewire.nix
    ./printing.nix
    ./xserver.nix
    ./zerotierone.nix
  ];

  home-manager.users.brunhild = {
    imports = [
      ./spotifyd.nix
    ];
  };

  environment.systemPackages = [
    pkgs.brave
    pkgs.dbeaver-bin
    pkgs.dragon-drop
    pkgs.easyeffects
    pkgs.google-chrome
    pkgs.grim
    pkgs.obs-studio
    pkgs.slurp
    pkgs.spotify-player
    pkgs.thunar
    pkgs.udevil
    pkgs.vesktop
    pkgs.vlc
    pkgs.wl-clipboard
    pkgs.xwayland-satellite
  ];

  programs = {
    niri.enable = true;
    steam.enable = true;
  };

  services = {
    devmon.enable = true;
    gnome.gcr-ssh-agent.enable = false;
    pulseaudio.enable = false;
    upower.enable = true;
  };
}
