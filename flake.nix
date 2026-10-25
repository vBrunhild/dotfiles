{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # hplip 3.26.4 fails to build: https://github.com/NixOS/nixpkgs/issues/575306
    # fixed by https://github.com/NixOS/nixpkgs/pull/575319, drop this input once it reaches nixpkgs-unstable
    # (check with https://nixpk.gs/pr-tracker.html?pr=575319)
    nixpkgs-hplip = {
      url = "github:NixOS/nixpkgs/50e858825dda8c0293d9dcae4af90456da5c26f2";
      flake = false;
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:denful/import-tree";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-wrapper-modules = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sem = {
      url = "github:Ataraxy-Labs/sem/v0.27.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nu-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    delta = {
      url = "github:zed-industries/delta-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    path-server = {
      url = "github:kunlinglio/path-server";
      flake = false;
    };

    zjstatus = {
      url = "github:dj95/zjstatus?ref=v0.25.0";
      flake = false;
    };

    zellij-autolock = {
      url = "github:fresh2dev/zellij-autolock?ref=0.3.0";
      flake = false;
    };

    bitbucket-cli = {
      url = "github:avivsinai/bitbucket-cli?ref=v0.32.1";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    (inputs.import-tree ./modules);
}
