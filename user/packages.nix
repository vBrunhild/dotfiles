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
        bat
        bottom
        curl
        direnv
        fd
        fish
        git
        git-credential-manager
        jujutsu
        nh
        openssh
        ripgrep
        starship
        tealdeer
        tinymist
        typst
        uutils-coreutils-noprefix
        wezterm
        wikiman
        zellij
        zoxide
      ;
    }
    ++ [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
}
