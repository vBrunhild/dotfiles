{ pkgs, ... }:
let
  inherit (pkgs) fetchurl;
  inherit (pkgs.stdenv) mkDerivation;

  zellij-autolock = mkDerivation rec {
    name = "zellij-autolock";
    version = "0.2.2";

    src = fetchurl {
      url = "https://github.com/fresh2dev/${name}/releases/download/${version}/${name}.wasm";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  zellij-plugins = pkgs.symlinkJoin {
    name = "zellij-plugins";
    paths = [
      zellij-autolock
    ];
  };
in
  pkgs.symlinkJoin {
    name = "zellij-wrapped";
    paths = [ pkgs.zellij ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zellij --add-flags "--plugins=${zellij-plugins}"
    '';
  }
