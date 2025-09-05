{pkgs, ...}: {
  homix = {
    ".config/nushell/config.nu".text =
      # nu
      ''
        source ${./theme.nu}
        source ${./zoxide.nu}

        # def git_status [] {
        #   let lines = (git status --porcelain=2
        #     | lines
        #     | each {|line|
        #         let parts = $line | split row ' '
        #         { status: ($parts | get 1), file: ($parts | get 8) }
        #     })
        #   {
        #     staged: ($lines | where ($it | (str substring 0..0) == ' ') | length)
        #     modified: ($lines | where ($it) | length)
        #     untracked: ($lines | where ($it | str starts-with "??") | length)
        #     deleted: ($lines | where ($it | str starts-with " d") | length)
        #   }
        # }

        def git_info [] {
          if (git rev-parse --is-inside-work-tree) {
            let branch = (git rev-parse --abrev-ref HEAD | str trim)
            let commit = (git rev-parse --short HEAD | str trim)
            let status = (git status --porcelain=v1 --branch | lines)
          }
        }

        $env.config.hooks = {
          env_change: {
            PWD: ($env.config.hooks.env_change.PWD? | default [] | append { ||
                if (which direnv | is-empty) {
                    return
                }
                direnv export json | from json | default {} | load-env
              }
            )
          }
        }

        $env.config.show_banner = false
        $env.config.edit_mode = "vi"
        $env.config.completions.algorithm = "fuzzy"

        plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        def start_zellij [] {
          if 'ZELLIJ' not-in ($env | columns) {
            if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
              zellij attach -c
            } else {
              zellij
            }
            if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
              exit
            }
          }
        }

        start_zellij
    '';
  ".config/nushell/env.nu".text =
    # nu
    ''
    '';
  };
}
