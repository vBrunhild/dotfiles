rec
{
  packages = pkgs: let
    inherit (pkgs) callPackage;
  in {
    helix = pkgs.helix;
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
          helix
          fish
        ;
      };
    };

  module = { pkgs, ... }:
  {
    config = {
      environment.systemPackages = builtins.attrValues (packages pkgs);

      programs.fish.enable = true;
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
