{
  nixpkgs,
  self,
  ...
}: let
  inherit (self) inputs;

  mkHost = name: system:
    nixpkgs.lib.nixosSystem {
      modules =
        [
          {
            networking.hostName = name;
            nixpkgs.hostPlatform = system;
          }
          ./${name}.nix
        ]
        ++ builtins.attrValues self.nixosModules;

      specialArgs = {
        inherit inputs;
        flake = self;
      };
    };
in {
  proteus = mkHost "proteus" "x86_64-linux";
}
