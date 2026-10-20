{config, ...}: let
  inherit (config.meta) dotfiles username;
  hm = config.flake.modules.homeManager;
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
        ".claude/scripts".source =
          mkOutOfStoreSymlink
          "${claudePath}/scripts";

        ".claude/skills/playwright-cli".source = "${playwright-cli.src}/skills/playwright-cli";
      }
      // linkDirs "skills"
      // linkDirs "plugins";
  };
}
