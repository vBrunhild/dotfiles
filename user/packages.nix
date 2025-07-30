{
  pkgs,
  inputs,
  ...
}: let
  inherit (builtins) attrValues;
in {
  environment.systemPackages =
    attrValues {
      inherit
        (pkgs)
        bottom
        curl
        direnv
        docker
        fish
        git
        git-credential-manager
        nh
        ripgrep
        starship
        stow
        uutils-coreutils-noprefix
        wezterm
        zellij
        zoxide
        ;
    }
    ++ [inputs.zen-browser.packages.${pkgs.system}.default];
}
