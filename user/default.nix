rec {
  packages = {inputs, pkgs}: let
    inherit (pkgs) callPackage;
  in {
    neovim = callPackage ./wrapped/neovim {inherit inputs;};
    zellijPlugins = callPackage ./wrapped/zellij-plugins.nix {};
  };

  module = {inputs, pkgs, ...}: {
    config = {
      environment = {
        systemPackages = builtins.attrValues (packages {inherit inputs pkgs;});
        pathsToLink = ["/share/zellij-plugins"];
        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };

      programs.bat.enable = true;
      programs.direnv.enable = true;
      programs.ssh.startAgent = true;
      programs.zoxide.enable = true;
    };

    imports = [
      ./config
      ./git.nix
      ./packages.nix
    ];
  };
}
