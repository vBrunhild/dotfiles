{pkgs, ...}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "1962818";
    hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
  };
in {
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

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter directory or open file";
        }
      ];
    };

    theme = {
      mgr = {
        cwd = {fg = "#61afef";};
        find_keyword = {
          fg = "#c678dd";
          bold = true;
          italic = true;
          underline = true;
        };
        find_position = {
          fg = "#98c379";
          bg = "reset";
          bold = true;
          italic = true;
        };
        marker_copied = {
          fg = "#98c379";
          bg = "#98c379";
        };
        marker_cut = {
          fg = "#e06c75";
          bg = "#e06c75";
        };
        marker_marked = {
          fg = "#c678dd";
          bg = "#c678dd";
        };
        marker_selected = {
          fg = "#e5c07b";
          bg = "#e5c07b";
        };
        count_copied = {
          fg = "#282c34";
          bg = "#98c379";
        };
        count_cut = {
          fg = "#282c34";
          bg = "#e06c75";
        };
        count_selected = {
          fg = "#282c34";
          bg = "#e5c07b";
        };
        border_symbol = "│";
        border_style = {fg = "#3e4451";};
      };

      tabs = {
        active = {
          fg = "#282c34";
          bg = "#98c379";
          bold = true;
        };
        inactive = {
          fg = "#abb2bf";
          bg = "#3e4451";
        };
      };

      mode = {
        normal_main = {
          fg = "#282c34";
          bg = "#98c379";
          bold = true;
        };
        normal_alt = {
          fg = "#98c379";
          bg = "#3e4451";
        };
        select_main = {
          fg = "#282c34";
          bg = "#c678dd";
          bold = true;
        };
        select_alt = {
          fg = "#c678dd";
          bg = "#3e4451";
        };
        unset_main = {
          fg = "#282c34";
          bg = "#e06c75";
          bold = true;
        };
        unset_alt = {
          fg = "#e06c75";
          bg = "#3e4451";
        };
      };

      status = {
        perm_sep = {fg = "#5c6370";};
        perm_type = {fg = "#61afef";};
        perm_read = {fg = "#e5c07b";};
        perm_write = {fg = "#e06c75";};
        perm_exec = {fg = "#98c379";};
        progress_label = {
          fg = "#abb2bf";
          bold = true;
        };
        progress_normal = {
          fg = "#98c379";
          bg = "#3e4451";
        };
        progress_error = {
          fg = "#e06c75";
          bg = "#181a1f";
        };
      };

      pick = {
        border = {fg = "#c678dd";};
        active = {
          fg = "#98c379";
          bold = true;
        };
        inactive = {};
      };

      input = {
        border = {fg = "#c678dd";};
        title = {};
        value = {};
        selected = {reversed = true;};
      };

      cmp = {
        border = {fg = "#c678dd";};
      };

      tasks = {
        border = {fg = "#98c379";};
        title = {};
        hovered = {
          fg = "#c678dd";
          bold = true;
        };
      };

      which = {
        mask = {bg = "#3e4451";};
        cand = {fg = "#61afef";};
        rest = {fg = "#5c6370";};
        desc = {fg = "#c678dd";};
        separator = "  ";
        separator_style = {fg = "#3e4451";};
      };

      help = {
        on = {fg = "#98c379";};
        run = {fg = "#c678dd";};
        hovered = {
          reversed = true;
          bold = true;
        };
        footer = {
          fg = "#abb2bf";
          bg = "#3e4451";
        };
      };

      spot = {
        border = {fg = "#61afef";};
        title = {fg = "#61afef";};
        tbl_col = {fg = "#c678dd";};
        tbl_cell = {
          fg = "#abb2bf";
          bg = "#181a1f";
        };
      };

      notify = {
        title_info = {fg = "#98c379";};
        title_warn = {fg = "#e5c07b";};
        title_error = {fg = "#e06c75";};
      };

      filetype = {
        rules = [
          {
            mime = "image/*";
            fg = "#61afef";
          }
          {
            mime = "{audio,video}/*";
            fg = "#e5c07b";
          }
          {
            mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
            fg = "#c678dd";
          }
          {
            mime = "application/{pdf,doc,rtf}";
            fg = "#98c379";
          }
          {
            mime = "vfs/{absent,stale}";
            fg = "#5c6370";
          }
          {
            url = "*";
            fg = "#abb2bf";
          }
          {
            url = "*/";
            fg = "#98c379";
          }
        ];
      };

      icon = {
        dirs = [
          {
            name = ".config";
            text = "";
            fg = "#c678dd";
          }
          {
            name = ".git";
            text = "";
            fg = "#e06c75";
          }
          {
            name = ".github";
            text = "";
            fg = "#abb2bf";
          }
          {
            name = "Desktop";
            text = "";
            fg = "#abb2bf";
          }
          {
            name = "Development";
            text = "";
            fg = "#98c379";
          }
          {
            name = "Documents";
            text = "";
            fg = "#98c379";
          }
          {
            name = "Downloads";
            text = "";
            fg = "#98c379";
          }
          {
            name = "Movies";
            text = "";
            fg = "#c678dd";
          }
          {
            name = "Music";
            text = "";
            fg = "#c678dd";
          }
          {
            name = "Pictures";
            text = "";
            fg = "#c678dd";
          }
        ];
        conds = [
          {
            "if" = "orphan";
            text = "";
            fg = "#e06c75";
          }
          {
            "if" = "link";
            text = "";
            fg = "#61afef";
          }
          {
            "if" = "block";
            text = "";
            fg = "#e5c07b";
          }
          {
            "if" = "char";
            text = "";
            fg = "#e5c07b";
          }
          {
            "if" = "dummy";
            text = "";
            fg = "#e06c75";
          }
          {
            "if" = "dir & hovered";
            text = "";
            fg = "#98c379";
            bold = true;
          }
          {
            "if" = "dir";
            text = "";
            fg = "#98c379";
          }
          {
            "if" = "exec";
            text = "";
            fg = "#98c379";
          }
          {
            "if" = "!dir";
            text = "";
            fg = "#abb2bf";
          }
        ];
      };
    };

    plugins = {
      smart-enter = "${yazi-plugins}/smart-enter.yazi";
    };

    initLua =
      # lua
      ''
        require("smart-enter"):setup({})
      '';
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
