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
  home.file =
    {
      ".claude/settings.json".source =
        mkOutOfStoreSymlink
        "${claudePath}/settings.json";

      ".claude/scripts".source =
        mkOutOfStoreSymlink
        "${claudePath}/scripts";

      ".claude/skills/playwright-cli".source = "${pkgs.playwright-cli.src}/skills/playwright-cli";
    }
    // linkDirs "skills"
    // linkDirs "plugins";
}
