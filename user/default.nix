rec {
  packages =
    pkgs:
    let
      inherit (pkgs) callPackage;
    in
    {
      neovim = callPackage ./wrapped/neovim { };
      zellijPlugins = callPackage ./wrapped/zellij-plugins.nix { };
    };

  module =
    { pkgs, ... }:
    {
      config = {
        environment = {
          systemPackages = builtins.attrValues (packages pkgs);
          variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };
          pathsToLink = [ "/share/zellij-plugins" ];
        };

        programs.fish = {
          enable = true;
          interactiveShellInit =
            # fish
            ''
              set fish_greeting
              eval (zellij setup --generate-auto-start fish | string collect)
            '';
        };

        programs.bat.enable = true;
        programs.direnv.enable = true;
        programs.ssh.startAgent = true;
        programs.starship.enable = true;
        programs.zoxide.enable = true;

        # stop fish from increasing build times by an ridiculous amount
        documentation.man.generateCaches = false;
      };

      imports = [
        ./config
        ./git.nix
        ./packages.nix
      ];
    };
}
