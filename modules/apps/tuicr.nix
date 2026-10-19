{config, ...}: let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;

  palette = config.palette.withHashtag;
  inherit (config.palette.lib) mix;
in {
  flake.modules.nixos.tuicr = {pkgs, ...}: {
    environment.systemPackages = [pkgs.tuicr];
    home-manager.users.${username}.imports = [hm.tuicr];
  };

  flake.modules.homeManager.tuicr = {pkgs, ...}: let
    toml = pkgs.formats.toml {};

    theme = with palette; let
      addBg = mix 0.2 green background;
      delBg = mix 0.2 red background;
    in {
      panel_bg = background;
      bg_highlight = dark-gray;
      fg_primary = white;
      fg_secondary = foreground;
      fg_dim = light-gray;

      diff_add = green;
      diff_add_bg = addBg;
      diff_del = red;
      diff_del_bg = delBg;
      diff_context = white;
      diff_hunk_header = blue;
      expanded_context_fg = light-gray;

      syntax_add_bg = addBg;
      syntax_del_bg = delBg;

      file_added = green;
      file_modified = yellow;
      file_deleted = red;
      file_renamed = purple;

      reviewed = green;
      pending = yellow;

      comment_note = blue;
      comment_suggestion = cyan;
      comment_issue = red;
      comment_praise = green;

      border_focused = primary;
      border_unfocused = dark-gray;
      status_bar_bg = black;
      cursor_color = yellow;
      cursor_line_bg = mix 0.5 dark-gray background;
      branch_name = purple;
      help_indicator = light-gray;

      message_info_fg = background;
      message_info_bg = blue;
      message_warning_fg = background;
      message_warning_bg = yellow;
      message_error_fg = background;
      message_error_bg = red;
      update_badge_fg = background;
      update_badge_bg = yellow;

      mode_fg = background;
      mode_bg = primary;
    };
  in {
    xdg.configFile = {
      "tuicr/themes/palette.toml".source = toml.generate "tuicr-palette.toml" theme;
      "tuicr/config.toml".source = toml.generate "tuicr-config.toml" {theme = "palette";};
    };
  };
}
