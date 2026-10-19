{
  inputs,
  craneLib,
  ...
}: let
  args = {
    src = inputs.path-server;
    strictDeps = true;
  };

  cargoArtifacts = craneLib.buildDepsOnly args;
in
  craneLib.buildPackage (args
    // {
      inherit cargoArtifacts;
    })
