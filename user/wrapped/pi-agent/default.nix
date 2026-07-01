{
  pkgs,
  inputs,
  config,
  ...
}: let
  theme = import ./theme.nix {
    inherit pkgs;
    palette = config.palette.withHashtag;
  };
  packages = import ./packages.nix {inherit pkgs inputs;};

  jail = inputs.jail-nix.lib.extend {
    inherit pkgs;
    basePermissions = c: [
      (c.add-path "/bin")
      (c.fwd-env "HOME")
      (c.fwd-env "LANG")
      (c.fwd-env "TERM")
      (c.ro-bind "${pkgs.bash}/bin/sh" "/bin/sh")
      (c.unsafe-add-raw-args "--clearenv")
      (c.unsafe-add-raw-args "--dev /dev")
      (c.unsafe-add-raw-args "--proc /proc")
      (c.unsafe-add-raw-args "--tmpfs /tmp")
      (c.unsafe-add-raw-args "--tmpfs ~")
      c.bind-nix-store-runtime-closure
      c.fake-passwd
    ];
  };

  jailed-pi = jail "pi" pkgs.pi-coding-agent (c: let
    pi-dir = "/home/brunhild/dotfiles/user/wrapped/pi-agent/agent";

    home = path: c.noescape "~/${path}";
    cwd = path: c.noescape "\"$PWD/${path}\"";

    ro-pi-skills-dir = c.ro-bind "${pi-dir}/skills" (home ".pi/agent/skills");
    ro-pi-theme = c.bind-pkg (home ".pi/agent/themes/default.json") theme;
    rw-pi-settings = c.rw-bind "${pi-dir}/settings.json" (home ".pi/agent/settings.json");

    ro-git-dir = c.try-readonly (cwd ".git");

    devenv =
      c.add-runtime
      # bash
      ''
        if [ -f "$PWD/flake.nix" ] && [ -f "$PWD/flake.lock" ]; then
          if dev_path="$(${pkgs.nix}/bin/nix develop .#agent --accept-flake-config --command ${pkgs.coreutils}/bin/printenv PATH 2>/dev/null)"; then
            :
          fi
          jail_path=

          old_ifs="$IFS"
          IFS=:
          for path_entry in $dev_path; do
            IFS="$old_ifs"
            case "$path_entry" in
              /nix/store/*/bin)
                package="''${path_entry%/bin}"
                jail_path="''${jail_path:+$jail_path:}$path_entry"
                while read -r dependency; do
                  RUNTIME_ARGS+=(--ro-bind "$dependency" "$dependency")
                done < <(${pkgs.nix}/bin/nix-store --query --requisites "$package" 2>/dev/null)
                ;;
            esac
            IFS=:
          done
          IFS="$old_ifs"

          if [ -n "$jail_path" ]; then
            RUNTIME_ARGS+=(--setenv PATH "$jail_path")
          fi
        fi
      '';
  in [
    (c.add-pkg-deps packages)
    (c.persist-home "pi-agent")
    c.mount-cwd
    c.network
    c.no-new-session
    c.open-urls-in-browser
    c.time-zone
    devenv
    ro-git-dir
    ro-pi-skills-dir
    ro-pi-theme
    rw-pi-settings
  ]);
in
  pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [pkgs.systemd];
    text = ''
      exec systemd-run --user --scope --quiet --collect \
        --property=MemoryMax=4G \
        --property=MemorySwapMax=0 \
        --property=CPUQuota=200% \
        --property=TasksMax=512 \
        -- ${jailed-pi}/bin/pi "$@"
    '';
  }
