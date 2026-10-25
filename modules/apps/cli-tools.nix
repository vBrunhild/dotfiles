{
  flake.modules.nixos.cli-tools = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.awscli2
      pkgs.beans
      pkgs.curl
      pkgs.dust
      pkgs.eza
      pkgs.ffmpeg
      pkgs.jq
      pkgs.ouch-rar
      pkgs.pandoc
      pkgs.rclone
      pkgs.rsync
      pkgs.sd
      pkgs.tabiew
      pkgs.tealdeer
      pkgs.uutils-coreutils-noprefix
      pkgs.zerotierone
    ];
  };
}
