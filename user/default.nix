rec
{
  packages = pkgs: let
    inherit (pkgs) callPackage;
  in {
    neovim = callPackage ./wrapped/neovim.nix {};
    zellijPlugins = callPackage ./wrapped/zellij-plugins.nix {};
    fish = pkgs.fish;
  };

  shell = pkgs:
    pkgs.mkShell {
      name = "brunhild-devshell";
      shellHook = ''
        fish
      '';

      buildInputs = builtins.attrValues {
        inherit
          (packages pkgs)
          neovim
          fish
        ;
      };
    };

  module = { pkgs, ... }:
  {
    config = {
      environment = {
        systemPackages = builtins.attrValues (packages pkgs);
        sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
          SHELL = "${pkgs.fish}/bin/fish";
          RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/.ripgreprc";
        };
        pathsToLink = [ 
          "/share/zellij-plugins"
        ];
      };

      programs.fish.enable = true;
      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    imports = [
      ./packages.nix
      ./git.nix
    ];
  };
}
