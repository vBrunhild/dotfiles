{
  inputs,
  pkgs,
  ...
}: let
  zoxide-init =
    pkgs.runCommand
    "zoxide-init.nu"
    {nativeBuildInputs = [pkgs.zoxide];}
    ''
      zoxide init nushell > $out
    '';
in {
  programs.nushell = {
    enable = true;
    configFile.text =
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

        def start_zellij [] {
          if 'ZELLIJ' not-in ($env | columns) {
            zellij
            if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
              exit
            }
          }
        }

        start_zellij
      '';

    envFile.text =
      # nu
      ''
        $env.ZELLIJ_SOCKET_DIR = "/tmp/zellij"

        $env.config.completions.algorithm = "fuzzy"
        $env.config.edit_mode = "vi"
        $env.config.show_banner = false
      '';

    plugins = [
      pkgs.nushellPlugins.polars
      pkgs.nushellPlugins.query
    ];
  };
}
