rec
{
  packages = pkgs: let
    inherit (pkgs) callPackage;
  in {};

  shell = pkgs:
    pkgs.mkShell {
      name = "brunhild-devshell";
      shellHook = ''
        fish
      '';

      buildInput = builtins.attrValues {
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

      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    imports = [
      ./packages.nix
      ./git
    ];
  };
}
