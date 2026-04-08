let
  packages = {
    inputs,
    pkgs,
  }: let
    inherit (pkgs) callPackage;
  in {
    neovim = callPackage ./wrapped/neovim {inherit inputs;};
    zellijPlugins = callPackage ./wrapped/zellij-plugins.nix {};
  };
in {
  inherit packages;

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

      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
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
