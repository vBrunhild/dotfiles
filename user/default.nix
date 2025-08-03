rec {
  packages = pkgs: let
    inherit (pkgs) callPackage;
  in {
    fish = pkgs.fish;
    neovim = callPackage ./wrapped/neovim.nix {};
    zellijPlugins = callPackage ./wrapped/zellij-plugins.nix {};
  };

  module = {pkgs, ...}: {
    config = {
      environment = {
        systemPackages = builtins.attrValues (packages pkgs);
        variables = {
          RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/.ripgreprc";
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
        pathsToLink = ["/share/zellij-plugins"];
      };

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
        '';
      };

      programs.zoxide.enable = true;
      programs.starship.enable = true;
      programs.direnv.enable = true;

      # stop fish from increasing build times by an ridiculous amount
      documentation.man.generateCaches = false;
    };

    imports = [
      ./packages.nix
      ./git.nix
      ./homix-config.nix
    ];
  };
}
