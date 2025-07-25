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
          RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/.ripgreprc";
        };
        pathsToLink = [ 
          "/share/zellij-plugins"
        ];
      };

      programs.fish = { 
        enable = true;
        interactiveShellInit = ''
          set fish_greeting 
        '';
        shellInit = ''
          starship init fish | source
          zoxide init fish | source
        '';
      };

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
