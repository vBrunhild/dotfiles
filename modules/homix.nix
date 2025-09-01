{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    attrValues
    filterAttrs
    flatten
    mkDerivedConfig
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (builtins) map attrNames;
in {
  options = {
    homix = mkOption {
      default = {};
      type = types.attrsOf (
        types.submodule (
          {
            name,
            config,
            options,
            ...
          }: {
            options = {
              path = mkOption {
                type = types.str;
                description = ''
                  Path to the file relative to the $HOME directory.
                  If not defined, name of the attribute set will be used.
                '';
                default = name;
              };
              source = mkOption {
                type = types.path;
                description = "Path of the source file or directory";
              };
              text = mkOption {
                default = null;
                type = types.nullOr types.lines;
                description = "Text of the file";
              };
            };
            config = {
              source = mkIf (config.text != null) (
                let
                  name' = "homix-" + lib.replaceStrings ["/"] ["-"] name;
                in
                  mkDerivedConfig options.text (pkgs.writeText name')
              );
            };
          }
        )
      );
    };
    users.users = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.homix = mkEnableOption "Enable homix for selected user";
        }
      );
    };
  };

  config = let
    users = attrNames (filterAttrs (name: user: user.homix) config.users.users);

    mkTmpfilesRules = user: let
      home = config.users.users.${user}.home;
      uid = toString config.users.users.${user}.uid;
      group = toString config.users.users.${user}.group;
    in
      map (file: "L+ ${home}/${file.path} - ${uid} ${group} - ${file.source}") (attrValues config.homix);

    mkActivationScript = user: let
      home = config.users.users.${user}.home;
      uid = toString config.users.users.${user}.uid;
      group = toString config.users.users.${user}.group;
      gid = toString config.users.groups.${group}.gid;

      dirs = lib.unique (map (
        file:
          builtins.dirOf "${home}/${file.path}"
      ) (attrValues config.homix));

      mkdirCommands =
        map (dir: ''
          if [ ! d "${dir}" ]; then
            mkdir -p "${dir}"
            chown ${uid}:${gid} "${dir}"
          fi
        '')
        dirs;
    in
      builtins.concatStringsSep "\n" mkdirCommands;

    tmpfilesRules = flatten (map mkTmpfilesRules users);
    activationScript = lib.genAttrs users (user: {text = mkActivationScript user;});
  in {
    systemd.tmpfiles.rules = tmpfilesRules;
    system.activationScripts = activationScript;
  };
}
