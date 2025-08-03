{
  pkgs,
  inputs,
  ...
}: let
  inherit (builtins) attrValues;
in {
  environment.systemPackages =
    attrValues {
      inherit (pkgs)
        bottom
        curl
        direnv
        fish
        git
        git-credential-manager
        nh
        ripgrep
        starship
        uutils-coreutils-noprefix
        wezterm
        zellij
        zoxide
        ;
    }
    ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
