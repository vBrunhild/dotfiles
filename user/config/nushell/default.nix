{pkgs, ...}: {
  homix = {
    ".config/nushell/config.nu".text =
      # nu
      ''
        $env.config.show_banner = false
        $env.config.edit_mode = "vi"
        $env.config.completions.algorithm = "fuzzy"

        plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        # init starship
        mkdir ($nu.data-dir | path join "vendor/autoload")
        starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

        # init zoxide
        source ~/.zoxide.nu

        # init zellij
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
        zoxide init nushell | save -f ~/.zoxide.nu
      '';
  };
}
