{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config) meta;
  inherit (config.flake) wrappers;
  palette = config.palette.withHashtag;

  autolockIgnoredPrograms = [
    "zellij"
    "sh"
    "ash"
    "dash"
    "bash"
    "zsh"
    "fish"
    "ksh"
    "mksh"
    "csh"
    "tcsh"
    "nu"
    "xonsh"
    "elvish"
    "pwsh"
    "powershell"
    "cmd"
    "ls"
    "lsd"
    "eza"
    "starship"
    "direnv"
    ''\\(atuin\\)''
    "atuin history start.*"
    "just"
    "ssh"
  ];

  autolockIgnore = [
    ''^(${builtins.concatStringsSep "|" autolockIgnoredPrograms})(\\.exe)?$''
    ''^(.*/)?(docker|podman) (compose (.* )?)?logs( .*)?$''
    ''^(.*/)?(docker|podman) compose (.* )?up( .*)?$''
  ];

  theme = with palette; let
    component = background: base: emphasis: {
      inherit background base;
      emphasis_0 = builtins.elemAt emphasis 0;
      emphasis_1 = builtins.elemAt emphasis 1;
      emphasis_2 = builtins.elemAt emphasis 2;
      emphasis_3 = builtins.elemAt emphasis 3;
    };

    accents = [orange blue cyan red];
    selected = component foreground white accents;
    unselected = component black white accents;
  in {
    exit_code_error = component background red [yellow background background background];
    exit_code_success = component background cyan [blue black red primary];
    frame_highlight = component background red [red orange orange orange];
    frame_selected = component background purple [orange blue red background];
    list_selected = selected;
    list_unselected = unselected;
    ribbon_selected = component purple black [red orange red primary];
    ribbon_unselected = component dark-gray white [red white primary red];
    table_cell_selected = selected;
    table_cell_unselected = unselected;
    table_title = component background purple accents;
    text_selected = selected;
    text_unselected = unselected;
    multiplayer_user_colors = {
      player_1 = red;
      player_2 = primary;
      player_3 = background;
      player_4 = yellow;
      player_5 = blue;
      player_6 = background;
      player_7 = red;
      player_8 = background;
      player_9 = background;
      player_10 = background;
    };
  };

  toKdl = indent: name: attrs:
    "${indent}${name} {\n"
    + lib.concatStrings (lib.mapAttrsToList (key: value:
      if builtins.isAttrs value
      then toKdl "${indent}    " key value
      else "${indent}    ${key} \"${value}\"\n")
    attrs)
    + "${indent}}\n";

  plugins = pkgs: let
    rustPkgs = pkgs.extend (import inputs.rust-overlay);

    craneLib = (inputs.crane.mkLib rustPkgs).overrideToolchain (
      p: p.rust-bin.stable.latest.default.override {targets = ["wasm32-wasip1"];}
    );

    mkWasmPlugin = src: args: let
      common = {
        inherit src;
        cargoExtraArgs = "--target wasm32-wasip1";
        doCheck = false;
      };
    in
      craneLib.buildPackage (common
        // {
          strictDeps = true;
          cargoArtifacts = craneLib.buildDepsOnly common;
        }
        // args);
  in {
    zjstatus = mkWasmPlugin (craneLib.cleanCargoSource inputs.zjstatus) {
      doNotSign = true;
      buildInputs = [pkgs.libiconv];
    };

    zellij-autolock = mkWasmPlugin inputs.zellij-autolock {version = "0.3.0";};
  };
in {
  perSystem = {pkgs, ...}: {
    packages = plugins pkgs;
  };

  flake.wrappers.zellij = {
    lib,
    pkgs,
    wlib,
    ...
  }: let
    inherit (plugins pkgs) zellij-autolock zjstatus;
    configDir = "${placeholder "out"}/zellij-config";
  in {
    imports = [wlib.modules.default];

    package = lib.mkDefault pkgs.zellij;

    env.ZELLIJ_CONFIG_DIR = configDir;

    constructFiles.config = {
      relPath = "zellij-config/config.kdl";
      content =
        builtins.readFile ./config.kdl
        + toKdl "" "themes" {palette = theme;}
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
                  is_enabled true
                  lock_regex ".*"
                  ignore_regex "${builtins.concatStringsSep "|" autolockIgnore}"
              }
              zjstatus location="file:${zjstatus}/bin/zjstatus.wasm"
          }

          load_plugins {
              autolock
              zjstatus
          }
        '';
    };

    constructFiles.layout = {
      relPath = "zellij-config/layouts/default.kdl";
      content =
        # kdl
        ''
          layout {
              default_tab_template {
                  children
                  pane size=1 borderless=true {
                      plugin location="zjstatus" {
                          hide_frame_for_single_pane "true"

                          format_left  "{mode} #[fg=magenta,bold]{session} {tabs}"
                          format_right "{datetime}"
                          format_space ""

                          tab_active           "#[fg=green,bold]{index}"
                          tab_normal           "#[fg=white]{index}"
                          tab_separator        " "
                          tab_zero_based_index "true"

                          datetime          "#[fg=magenta] {format}"
                          datetime_format   "%d/%m/%Y %T"
                          datetime_timezone "${meta.timeZone}"

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
    };
  };

  flake.modules.nixos.zellij = {
    imports = [wrappers.zellij.install];
    wrappers.zellij.enable = true;
  };
}
