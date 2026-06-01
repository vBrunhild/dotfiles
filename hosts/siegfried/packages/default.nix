{pkgs, ...}: {
  imports = [
    ./avahi.nix
    ./foot.nix
    ./greetd.nix
    ./niri
    ./noctalia
    ./pipewire.nix
    ./printing.nix
    ./sioyek.nix
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
    pkgs.udevil
    pkgs.vesktop
    pkgs.vlc
    pkgs.wl-clipboard
    pkgs.xwayland-satellite
  ];

  programs = {
    steam.enable = true;
    thunar.enable = true;
  };

  services = {
    devmon.enable = true;
    gnome.gcr-ssh-agent.enable = false;
    gnome.gnome-keyring.enable = true;
    power-profiles-daemon.enable = true;
    pulseaudio.enable = false;
    tumbler.enable = true;
    upower.enable = true;
  };
}
