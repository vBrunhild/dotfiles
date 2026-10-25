{
  flake.modules.nixos.gui-apps = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.brave
      pkgs.dbeaver-bin
      pkgs.dragon-drop
      pkgs.easyeffects
      pkgs.google-chrome
      pkgs.graphite
      pkgs.grim
      pkgs.obs-studio
      pkgs.remmina
      pkgs.slurp
      pkgs.udevil
      # pkgs.vesktop
      pkgs.vlc
      pkgs.wl-clipboard
    ];
  };
}
