{inputs, ...}: let
  packages = pkgs: rec {
    path-server = pkgs.callPackage ./_path-server.nix {
      inherit inputs;
      craneLib = inputs.crane.mkLib pkgs;
    };

    neovim = pkgs.callPackage ./_neovim.nix {inherit path-server;};
  };
in {
  perSystem = {pkgs, ...}: {
    packages = packages pkgs;
  };

  flake.modules.nixos.neovim = {pkgs, ...}: {
    environment.systemPackages = [(packages pkgs).neovim];

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
