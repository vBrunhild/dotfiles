{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  quickshell = inputs.quickshell.packages.${system}.quickshell;
in {
  imports = [
    ./avahi.nix
    ./foot.nix
    ./greeter.nix quickshell
    ./pipewire.nix
    ./printing.nix
    ./xserver.nix
    ./zerotierone.nix
  ];

  home-manager.users.brunhild.imports = [
    ./dank-material-shell.nix quickshell
    ./dsearch.nix
    ./satty.nix
    ./spotifyd.nix
  ];

  environment.systemPackages = [
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.dragon-drop
    pkgs.google-chrome
    pkgs.grim
    pkgs.obs-studio
    pkgs.opentofu
    pkgs.slurp
    pkgs.spotify-player
    pkgs.udevil
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
