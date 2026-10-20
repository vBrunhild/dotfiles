{config, ...}: let
  inherit (config.meta) dotfiles username;
  inherit (config.palette.lib) mix;
  hm = config.flake.modules.homeManager;

  theme = with config.palette.withHashtag; let
    shimmer = color: mix 0.3 white color;
    tint = amount: color: mix amount color background;
  in {
    name = "Palette";
    base = "dark";
    overrides = {
      claude = primary;
      claudeShimmer = shimmer primary;
      text = white;
      inverseText = background;
      inactive = mix 0.5 white light-gray;
      inactiveShimmer = shimmer (mix 0.5 white light-gray);
      subtle = light-gray;
      suggestion = blue;
      permission = blue;
      permissionShimmer = shimmer blue;
      remember = cyan;

      success = green;
      error = red;
      warning = yellow;
      warningShimmer = shimmer yellow;
      merged = purple;

      promptBorder = light-gray;
      promptBorderShimmer = shimmer light-gray;
      planMode = cyan;
      autoAccept = purple;
      bashBorder = orange;
      ide = blue;
      fastMode = orange;
      fastModeShimmer = shimmer orange;

      diffAdded = tint 0.25 green;
      diffRemoved = tint 0.25 red;
      diffAddedDimmed = tint 0.12 green;
      diffRemovedDimmed = tint 0.12 red;
      diffAddedWord = tint 0.45 green;
      diffRemovedWord = tint 0.45 red;

      userMessageBackground = black;
      userMessageBackgroundHover = tint 0.5 dark-gray;
      bashMessageBackgroundColor = black;
      memoryBackgroundColor = black;
      selectionBg = dark-gray;

      rate_limit_fill = primary;
      rate_limit_empty = dark-gray;

      red_FOR_SUBAGENTS_ONLY = red;
      blue_FOR_SUBAGENTS_ONLY = blue;
      green_FOR_SUBAGENTS_ONLY = green;
      yellow_FOR_SUBAGENTS_ONLY = yellow;
      purple_FOR_SUBAGENTS_ONLY = purple;
      orange_FOR_SUBAGENTS_ONLY = orange;
      pink_FOR_SUBAGENTS_ONLY = mix 0.5 red purple;
      cyan_FOR_SUBAGENTS_ONLY = cyan;
    };
  };
in {
  flake.modules.nixos.claude = {pkgs, ...}: let
    claude-code = pkgs.claude-code.override {
      manifest = {
        version = "2.1.293";
        platforms = {
          "linux-x64" = {
            binary = "claude.zst";
            checksum = "sha256-JXhto0fDBkHcbFBzPQkNd8tUDxBaYa9+mJW1bjn+FqU=";
          };
        };
      };
    };
  in {
    environment.systemPackages = [claude-code];
    home-manager.users.${username}.imports = [hm.claude];
  };

  flake.modules.homeManager.claude = {
    lib,
    config,
    pkgs,
    ...
  }: let
    claudePath = "${dotfiles}/modules/apps/claude";
    inherit (config.lib.file) mkOutOfStoreSymlink;
    playwright-cli = pkgs.callPackage ../playwright-cli/_package.nix {};

    linkDirs = dir:
      ./${dir}
      |> builtins.readDir
      |> lib.filterAttrs (_: type: type == "directory")
      |> lib.mapAttrs' (name: _:
        lib.nameValuePair ".claude/skills/${name}" {
          source = mkOutOfStoreSymlink "${claudePath}/${dir}/${name}";
        });
  in {
    # Direct symlink (no /nix/store hop) so Claude Code can write to it
    home.activation.claudeSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run mkdir -p ${config.home.homeDirectory}/.claude
      run ln -sfn ${claudePath}/settings.json ${config.home.homeDirectory}/.claude/settings.json
    '';

    home.file =
      {
        ".claude/themes/palette.json".text = builtins.toJSON theme;

        ".claude/scripts".source =
          mkOutOfStoreSymlink
          "${claudePath}/scripts";

        ".claude/skills/playwright-cli".source = "${playwright-cli.src}/skills/playwright-cli";
      }
      // linkDirs "skills"
      // linkDirs "plugins";
  };
}
