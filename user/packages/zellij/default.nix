{
  inputs,
  pkgs,
  osConfig,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  palette = osConfig.palette.withHashtag;

  inherit
    (inputs.zellij-plugins.packages.${system})
    zellij-autolock
    zjstatus
    ;
in {
  programs.zellij = {
    enable = true;
    extraConfig =
      builtins.readFile ./config.kdl
      +
      # kdl
      ''
        plugins {
            about location="zellij:about"
            compact-bar location="zellij:compact-bar" {
                tooltip "F1"
            }
            configuration location="zellij:configuration"
            filepicker location="zellij:strider" {
                cwd "/"
            }
            plugin-manager location="zellij:plugin-manager"
            session-manager location="zellij:session-manager"
            status-bar location="zellij:status-bar"
            strider location="zellij:strider"
            tab-bar location="zellij:tab-bar"
            welcome-screen location="zellij:session-manager" {
                welcome_screen true
            }
            autolock location="file:${zellij-autolock}/bin/zellij-autolock.wasm" {
                is_enable true
                triggers "nvim"
                reaction_seconds "0.3"
                print_to_log false
            }
            zjstatus location="file:${zjstatus}/bin/zjstatus.wasm"
        }

        load_plugins {
            autolock
            zjstatus
        }
      '';
  };

  xdg.configFile."zellij/layouts/default.kdl".text =
    # kdl
    ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="zjstatus" {
                      hide_frame_for_single_pane "false"

                      format_left  "{mode} #[fg=magenta,bold]{session} {tabs}"
                      format_right "{pipe_zjstatus_hints}{datetime}"
                      format_space ""

                      tab_active           "#[fg=green,bold]{index}"
                      tab_normal           "#[fg=white]{index}"
                      tab_separator        " "
                      tab_zero_based_index "true"

                      datetime          "#[fg=magenta] {format}"
                      datetime_format   "%d/%m/%Y %T"
                      datetime_timezone "${osConfig.time.timeZone}"

                      mode_enter_search    "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_locked          "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_move            "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_normal          "#[bg=${palette.primary},fg=${palette.background}] {name} "
                      mode_pane            "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_prompt          "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_rename_pane     "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_rename_tab      "#[bg=${palette.foreground},fg=${palette.background}] {name} "
                      mode_resize          "#[bg=${palette.secondary},fg=${palette.background}] {name} "
                      mode_scroll          "#[bg=${palette.yellow},fg=${palette.background}] {name} "
                      mode_search          "#[bg=${palette.blue},fg=${palette.background}] {name} "
                      mode_session         "#[bg=${palette.orange},fg=${palette.background}] {name} "
                      mode_tab             "#[bg=${palette.cyan},fg=${palette.background}] {name} "
                      mode_tmux            "#[bg=${palette.red},fg=${palette.background}] {name} "
                      mode_default_to_mode "normal"
                  }
              }
          }
      }
    '';
}
