{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus-hints = {
      url = "github:b0o/zjstatus-hints";
      flake = false;
    };

    zellij-autolock = {
      url = "github:fresh2dev/zellij-autolock?ref=0.2.2";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    allPkgs = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [(import inputs.rust-overlay)];
        }
    );

    mkWasmPackage = {
      craneLib,
      src,
      extraArgs ? {},
    }: let
      cargoArtifacts = craneLib.buildDepsOnly {
        inherit src;
        cargoExtraArgs = "--target wasm32-wasip1";
        doCheck = false;
      };
    in
      craneLib.buildPackage ({
          inherit src cargoArtifacts;
          strictDeps = true;
          cargoExtraArgs = "--target wasm32-wasip1";
          doCheck = false;
        }
        // extraArgs);
  in {
    packages = forAllSystems (system: let
      pkgs = allPkgs.${system};

      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (
        p: p.rust-bin.stable.latest.default.override {targets = ["wasm32-wasip1"];}
      );

      zellij-autolock = mkWasmPackage {
        inherit craneLib;
        src = inputs.zellij-autolock;
        extraArgs = {version = "0.2.2";};
      };

      zjstatus = inputs.zjstatus.packages.${system}.default;
    in {
      inherit
        zellij-autolock
        zjstatus
        ;
    });

    checks = forAllSystems (system: {
      inherit
        (self.packages.${system})
        zellij-autolock
        ;
    });
  };
}
