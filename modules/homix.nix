{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrValues
    filterAttrs
    flatten
    mkDerivedConfig
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (builtins) map listToAttrs attrNames;
in
{
  options = {
    homix = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          {
            name,
            config,
            options,
            ...
          }:
          {
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
                  name' = "homix-" + lib.replaceStrings [ "/" ] [ "-" ] name;
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

  config =
    let
      users = attrNames (filterAttrs (name: user: user.homix) config.users.users);

      homix-link =
        let
          files = map (
            file:
            # bash
            ''
              FILE="$HOME/${file.path}"

              mkdir -p "$(dirname $FILE)"

              if [ -d "$FILE" ]; then
                echo "HOMIX-ERROR: Directory exists at '$FILE'. Cannot overwrite directory with file link."
                exit 1
              elif [ -L "$FILE" ]; then
                echo "HOMIX-WARNING: Removing existing symlink '$FILE' before linking."
                unlink "$FILE"
              elif [ -f "$FILE" ]; then
                echo "HOMIX-WARNING: Renaming file '$FILE' to '$FILE.bak'."
                mv "$FILE" "$FILE.bak"
              fi

              ln -s ${file.source} $FILE
            '') (attrValues config.homix);
        in
        pkgs.writeShellScript "homix-link" ''
          #!/bin/sh
          set -e
          set -u
          ${builtins.concatStringsSep "\n" files}
        '';

      mkServices = user: [
        {
          name = "homix-link-${user}";
          value = {
            wantedBy = [ "multi-user.target" ];
            description = "Setup homix environment for ${user}.";
            serviceConfig = {
              Type = "oneshot";
              User = "${user}";
              ExecStart = "${homix-link}";
            };
            environment = {
              HOME = config.users.users.${user}.home;
            };
          };
        }
      ];

      services = listToAttrs (flatten (map mkServices users));
    in
    {
      systemd.services = services;
    };
}
