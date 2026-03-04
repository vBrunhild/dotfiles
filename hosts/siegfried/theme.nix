{pkgs, ...}: let
  colors = {
    bg = "#1e2127";
    bg-alt = "#282c34";
    fg = "#cdd4e1";
    fg-alt = "#abb2bf";

    primary = "#98c379";
    secondary = "#c678dd";
    tertiary = "#61afef";
    error = "#e06c75";
    warning = "#e5c07b";
    info = "#56b6c2";

    border = "#3e4451";
    shadow = "#181a1f";
    selection = "#3e4451";
  };
in {
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/Custom/Custom.kvconfig".text = ''
    [General]
    author=Auto-generated
    comment=OneDark theme
    x11drag=menubar_and_primary_toolbar
    alt_mnemonic=true
    left_tabs=true
    attach_active_tab=false
    mirror_doc_tabs=false
    group_toolbar_buttons=false
    toolbar_item_spacing=0
    toolbar_interior_spacing=2
    spread_progressbar=true
    composite=true
    menu_shadow_depth=6
    tooltip_shadow_depth=2
    splitter_width=7
    scroll_width=12
    scroll_arrows=false
    scroll_min_extent=50
    slider_width=6
    slider_handle_width=16
    slider_handle_length=16
    center_toolbar_handle=true
    check_size=16
    textless_progressbar=false
    progressbar_thickness=2
    menubar_mouse_tracking=true
    toolbutton_style=0
    double_click=false
    translucent_windows=false
    blurring=false
    popup_blurring=false
    vertical_spin_indicators=false
    spin_button_width=16
    fill_rubberband=false
    merge_menubar_with_toolbar=true
    small_icon_size=16
    large_icon_size=32
    button_icon_size=16
    toolbar_icon_size=16
    combo_as_lineedit=true
    animate_states=true
    button_contents_shift=false
    combo_menu=true
    hide_combo_checkboxes=true
    combo_focus_rect=true
    groupbox_top_label=true
    inline_spin_indicators=true
    joined_inactive_tabs=false
    layout_spacing=6
    layout_margin=9
    scrollbar_in_view=false
    transient_scrollbar=false
    transient_groove=false
    submenu_overlap=0
    tooltip_delay=-1
    tree_branch_line=true
    dialog_button_layout=0
    intense_selection=false

    [GeneralColors]
    window.color=${colors.bg}
    base.color=${colors.bg-alt}
    alt.base.color=${colors.bg}
    button.color=${colors.bg-alt}
    light.color=${colors.border}
    mid.light.color=${colors.border}
    mid.color=${colors.bg-alt}
    dark.color=${colors.shadow}
    highlight.color=${colors.primary}
    inactive.highlight.color=${colors.border}
    text.color=${colors.fg}
    window.text.color=${colors.fg}
    button.text.color=${colors.fg}
    disabled.text.color=${colors.fg-alt}
    tooltip.base.color=${colors.bg-alt}
    tooltip.text.color=${colors.fg}
    highlight.text.color=${colors.bg}
    link.color=${colors.tertiary}
    link.visited.color=${colors.secondary}

    [Hacks]
    transparent_ktitle_label=true
    transparent_dolphin_view=false
    transparent_pcmanfm_sidepane=false
    blur_translucent=false
    transparent_menutitle=true
    respect_darkness=true
    kcapacitybar_as_progressbar=true
    force_size_grip=true
    iconless_pushbutton=false
    iconless_menu=false
    disabled_icon_opacity=70
    lxqtmainmenu_iconsize=22
    normal_default_pushbutton=true
    single_top_toolbar=true
    tint_on_mouseover=0
    transparent_pcmanfm_view=false
    no_selection_tint=false
  '';

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Custom
  '';
}
