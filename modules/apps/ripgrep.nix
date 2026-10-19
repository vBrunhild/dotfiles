{config, ...}: let
  inherit (config.flake) wrappers;
in {
  flake.wrappers.ripgrep = {wlib, ...}: {
    imports = [wlib.wrapperModules.ripgrep];

    settings = {
      max-columns = 150;
      max-columns-preview = true;
      smart-case = true;
      hidden = true;
      glob = "!.git/*";
    };
  };

  flake.modules.nixos.ripgrep = {
    config,
    lib,
    ...
  }: {
    imports = [wrappers.ripgrep.install];

    # hiPrio: neovim bundles a plain ripgrep for standalone use
    environment.systemPackages = [(lib.hiPrio config.wrappers.ripgrep.wrapper)];
  };
}
