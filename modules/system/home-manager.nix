{
  config,
  inputs,
  ...
}: let
  inherit (config.meta) username;
in {
  flake.modules.nixos.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${username} = {
        home = {
          inherit username;
          homeDirectory = "/home/${username}";
          stateVersion = "25.11";
        };

        programs.home-manager.enable = true;
      };
    };
  };
}
