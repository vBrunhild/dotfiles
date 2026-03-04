{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        sort_by = "natural";
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=foot --title=filepicker ${pkgs.yazi}/bin/yazi
  '';
}
