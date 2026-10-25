{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) wrappers;
  inherit (config.meta) username;
in {
  flake.wrappers.nushell = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: let
    zoxide-init =
      pkgs.runCommand
      "zoxide-init.nu"
      {nativeBuildInputs = [pkgs.zoxide];}
      ''
        zoxide init nushell > $out
      '';

    nushell = pkgs.nushell.overrideAttrs (finalAttrs: old: {
      version = "0.116.1";
      src = pkgs.fetchFromGitHub {
        owner = "nushell";
        repo = "nushell";
        tag = finalAttrs.version;
        hash = "sha256-b62ICCP7Li88obcju4xBNVw7D+6TtRURrOUvzqcjHis=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src;
        name = "nushell-${finalAttrs.version}";
        hash = finalAttrs.passthru.cargoHash;
      };
      passthru =
        old.passthru
        // {
          cargoHash = "sha256-+81FRwTlR5NSJuoaH7KCK6Qy1DiU5/JKNqfaAhZmMes=";
        };
    });

    plugins = map (p: p.override {inherit nushell;}) [
      # pkgs.nushellPlugins.polars
      pkgs.nushellPlugins.query
    ];
  in {
    imports = [wlib.wrapperModules.nushell];

    package = nushell;

    # --config/--env-config also apply to `nu -c` and scripts, which would run start-zellij
    wrapperImplementation = lib.mkForce "nix";
    flags."--config" = lib.mkForce null;
    flags."--env-config" = lib.mkForce null;
    runShell = [
      ''
        case "$*" in
          "" | -l | --login | -i | --interactive)
            set -- --config=${config."config.nu".path} --env-config=${config."env.nu".path} "$@"
            ;;
        esac
      ''
    ];

    flags."--plugins" = "[${builtins.concatStringsSep ", " (map (p: "${p}/bin/${p.meta.mainProgram}") plugins)}]";

    "config.nu".content =
      # nu
      ''
        use ${./op.nu} *

        source ${./prompt.nu}
        source ${./theme.nu}
        source ${zoxide-init}

        source ${inputs.nu-scripts}/custom-completions/git/git-completions.nu
        source ${inputs.nu-scripts}/custom-completions/jj/jj-completions.nu
        source ${inputs.nu-scripts}/custom-completions/just/just-completions.nu
        source ${inputs.nu-scripts}/custom-completions/nix/nix-completions.nu
        source ${inputs.nu-scripts}/custom-completions/podman/podman-completions.nu
        source ${inputs.nu-scripts}/custom-completions/ssh/ssh-completions.nu
        source ${inputs.nu-scripts}/custom-completions/zellij/zellij-completions.nu

        $env.config.hooks = {
          env_change: {
            PWD: ($env.config.hooks.env_change.PWD? | default [] | append { ||
              if (which direnv | is-empty) {
                  return
              }
              direnv export json | from json | default {} | load-env
            })
          }
        }

        start-zellij
      '';

    "env.nu".content =
      # nu
      ''
        $env.ZELLIJ_SOCKET_DIR = "/tmp/zellij"

        $env.config.completions.algorithm = "fuzzy"
        $env.config.edit_mode = "vi"
        $env.config.show_banner = false
      '';
  };

  flake.modules.nixos.nushell = {config, ...}: {
    imports = [wrappers.nushell.install];
    wrappers.nushell.enable = true;

    environment.shells = [config.wrappers.nushell.wrapper];
    users.users.${username}.shell = config.wrappers.nushell.wrapper;
  };
}
