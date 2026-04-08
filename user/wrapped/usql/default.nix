{pkgs, ...}: let
  ovWrapper = pkgs.writeShellScriptBin "ov-usql" ''
    exec ${pkgs.ov}/bin/ov \
      --align \
      --alternate-rows \
      --column-delimiter "|" \
      --column-rainbow \
      --header 1 \
      --wrap=false \
      "$@"
  '';
in
  pkgs.symlinkJoin {
    name = "usql";
    nativeBuildInputs = [pkgs.makeWrapper];
    paths = [
      pkgs.usql
      ovWrapper
    ];
    postBuild = ''
      wrapProgram $out/bin/usql \
        --add-flags "--config ${./config.yaml}" \
        --set PAGER "$out/bin/ov-usql"
    '';
  }
