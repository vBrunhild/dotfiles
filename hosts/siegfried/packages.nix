{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.google-chrome
    pkgs.spotify
    pkgs.vlc
    pkgs.wezterm
  ];
}
