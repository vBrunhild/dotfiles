{
  config,
  pkgs,
  lib,
  ...
}: let
  claudePath = "${config.home.homeDirectory}/dotfiles/user/packages/claude";
  inherit (config.lib.file) mkOutOfStoreSymlink;

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
      ".claude/scripts".source =
        mkOutOfStoreSymlink
        "${claudePath}/scripts";

      ".claude/skills/playwright-cli".source = "${pkgs.playwright-cli.src}/skills/playwright-cli";
    }
    // linkDirs "skills"
    // linkDirs "plugins";
}
