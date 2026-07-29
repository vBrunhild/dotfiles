{
  flake,
  inputs,
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  wrapped = import ./wrapped {inherit pkgs inputs config;};
in {
  config = {
    environment.systemPackages =
      builtins.attrValues (flake.packages.${system} // wrapped);

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
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
}
