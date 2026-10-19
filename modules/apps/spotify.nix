{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.spotifyd = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];

    options.settings = lib.mkOption {
      type = wlib.types.structuredValueWith {typeName = "TOML";};
      default = {};
    };

    config = {
      package = lib.mkDefault pkgs.spotifyd;

      settings.global = {
        backend = "pulseaudio";
        bitrate = 320;
        device_type = "computer";
        volume_normalisation = true;
        zeroconf_port = 57621;
      };

      constructFiles.generatedConfig = {
        content = builtins.toJSON config.settings;
        relPath = "${config.binName}.conf";
        builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
      };

      flags."--config-path" = config.constructFiles.generatedConfig.path;
    };
  };

  flake.modules.nixos.spotify = {
    config,
    pkgs,
    ...
  }: let
    spotifyd = config.wrappers.spotifyd.wrapper;
  in {
    imports = [wrappers.spotifyd.install];
    wrappers.spotifyd.enable = true;

    environment.systemPackages = [pkgs.spotify];

    networking.firewall.allowedTCPPorts = [57621];

    systemd.user.services.spotifyd = {
      description = "spotify daemon";
      documentation = ["https://github.com/Spotifyd/spotifyd"];
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${spotifyd}/bin/spotifyd --no-daemon";
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}
