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
          ./${name}
        ]
        ++ builtins.attrValues self.nixosModules;

      specialArgs = {
        inherit inputs;
        flake = self;
      };
    };
in {
  etzel = mkHost "etzel" "x86_64-linux";
  siegfried = mkHost "siegfried" "x86_64-linux";
}
