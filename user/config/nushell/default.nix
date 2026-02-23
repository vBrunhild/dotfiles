{pkgs, ...}: {
  programs.nushell = {
    enable = true;
    configFile.text =
      # nu
      ''
        use ${./op.nu} *

        source ${./prompt.nu}
        source ${./theme.nu}

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

        $env.config.show_banner = false
        $env.config.edit_mode = "vi"
        $env.config.completions.algorithm = "fuzzy"
      '';

    envFile.text =
      # nu
      ''
        source ${./completions/git.nu}
        source ${./completions/jj.nu}
        source ${./completions/zoxide.nu}

        $env.ZELLIJ_SOCKET_DIR = "/tmp/zellij"
      '';

    plugins = [
      pkgs.nushellPlugins.polars
      pkgs.nushellPlugins.query
    ];
  };
}
