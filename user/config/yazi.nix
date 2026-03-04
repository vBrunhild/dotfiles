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

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = let
    yazi-wrapper = pkgs.writeShellScript "yazi-filepicker" ''
      #!/usr/bin/env sh

      multiple="$1"
      directory="$2"
      save="$3"
      path="$4"
      out="$5"
      debug="$6"

      set -e

      if [ "$debug" = 1 ]; then
          set -x
      fi

      cmd="${pkgs.yazi}/bin/yazi"
      termcmd="''${TERMCMD}"

      if [ "$save" = "1" ]; then
          # save a file
          set -- --chooser-file="$out" "$path"
      elif [ "$directory" = "1" ]; then
          # upload files from a directory
          set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
      elif [ "$multiple" = "1" ]; then
          # upload multiple files
          set -- --chooser-file="$out" "$path"
      else
          # upload only 1 file
          set -- --chooser-file="$out" "$path"
      fi

      command="$termcmd $cmd"
      for arg in "$@"; do
          # escape double quotes
          escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
          # escape special
          command="$command \"$escaped\""
      done

      sh -c "$command"

      if [ "$directory" = "1" ]; then
          if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
              cat "$out"".1" > "$out"
              rm "$out"".1"
          else
              rm "$out"".1"
          fi
      fi
    '';
  in
    # toml
    ''
      [filechooser]
      cmd=${yazi-wrapper}
      default_dir=$HOME
      env=TERMCMD=foot -T=filepicker
      open_mode=suggested
      save_mode=last
    '';
}
