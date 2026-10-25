{config, ...}: let
  inherit (config) palette;
in {
  flake.modules.nixos.console = {
    console.colors = with palette; [
      background
      red
      green
      yellow
      blue
      purple
      cyan
      white
      light-gray
      red
      green
      yellow
      blue
      purple
      cyan
      foreground
    ];
  };
}
