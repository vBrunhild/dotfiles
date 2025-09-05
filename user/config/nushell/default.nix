{pkgs, ...}: {
  homix = {
    ".config/nushell/config.nu".text =
      # nu
      ''
        plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        source ${./theme.nu}
        source ${./completions/cargo.nu}
        source ${./completions/git.nu}
        source ${./completions/zellij.nu}
        source ${./completions/zoxide.nu}

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

        $env.config.show_banner = false
        $env.config.edit_mode = "vi"
        $env.config.completions.algorithm = "fuzzy"
      '';

  ".config/nushell/env.nu".text =
    # nu
    ''
    '';
  };
}
