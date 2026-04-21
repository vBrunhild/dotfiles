let
  packages = {pkgs}: let
    inherit (pkgs) callPackage;
  in {
    usql = callPackage ./wrapped/usql {};
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
        systemPackages = builtins.attrValues (packages {inherit pkgs;});
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
      ./packages
      ./stylix.nix
    ];
  };
}
