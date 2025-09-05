{pkgs, ...}: {
  homix = {
    ".config/nushell/config.nu".text =
      # nu
      ''
        plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        source ${./git.nu}
        source ${./theme.nu}
        source ${./zellij.nu}
        source ${./zoxide.nu}

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
