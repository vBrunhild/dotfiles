{
  config,
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      path-server = pkgs.callPackage ./_path-server.nix {
        inherit inputs;
        craneLib = inputs.crane.mkLib pkgs;
      };

      neovim = pkgs.callPackage ./_neovim.nix {
        inherit (config.packages) path-server;
      };
    };
  };

  flake.modules.nixos.neovim = {pkgs, ...}: {
    environment.systemPackages = [
      config.flake.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    ];

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
