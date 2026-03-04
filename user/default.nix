rec {
  packages = {
    inputs,
    pkgs,
  }: let
    inherit (pkgs) callPackage;
  in {
    neovim = callPackage ./wrapped/neovim {inherit inputs;};
    zellijPlugins = callPackage ./wrapped/zellij-plugins.nix {};
  };

  module = {
    inputs,
    pkgs,
    ...
  }: {
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
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };

      virtualisation.docker = {enable = true;};

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        extraSpecialArgs = {inherit inputs;};
        users.brunhild = ./home.nix;
      };
    };

    imports = [
      ./config
      ./git.nix
      ./packages.nix
    ];
  };
}
