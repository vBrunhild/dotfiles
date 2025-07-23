{ config, lib, ... }:
let
    inherit (builtins) map;
    inherit (lib.strings) concatStringSep;
    inherit (lib) mkMerge forEach mkDefault mkIf mkEnableOption mkOption types;

    cfg = config.staypls;

    mkPersistentBindMounts = list:
        mkMerge (map (path: {
            "${path}" = {
                device = "/persist${path}";
                fsType = "none";
                options = [ "bind" "X-fstrim.notrim" "x-gvfs-hide" ];
            };
        }) list);

    mkPersistentSourcePaths = list: concatStringSep "\n" (forEach list (path: ''
        echo "staypls: Creating persistent directory /persist${path}"
        mkdir -p /persist${path}
    ''));
in {
    options.staypls = {
        enable = mkEnableOption "Enable directory impermanence module";
        dirs = mkOption {
            type = types.listOf types.str;
            description = "List of directories to mount";
        };
    };

    config = mkIf cfg.enable {
        boot.initrd.systemd.enable = mkDefault true;

        fileSystems = mkPersistentBindMounts cfg.dirs;
        boot.initrd.systemd.services.make-source-of-persistent-dirs = {
            wantedBy = ["initrd-root-device.target"];
            before = ["sysroot.mount"];
            requires = ["persist.mount"];
            after = ["persist.mount"];
            serviceConfig.Type = "oneshot";
            unitConfig.DefaultDependencies = false;
            script = mkPersistentSourcePaths cfg.dirs;
        };
    };
}
