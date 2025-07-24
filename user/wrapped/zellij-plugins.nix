{ pkgs, ... }:
let
  inherit (pkgs) fetchurl;
  inherit (pkgs.stdenv) mkDerivation;

  zellij-autolock = mkDerivation rec {
    name = "zellij-autolock";
    version = "0.2.2";

    src = fetchurl {
      url = "https://github.com/fresh2dev/${name}/releases/download/${version}/${name}.wasm";
      sha256 = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/zellij-plugins
      cp $src $out/share/zellij-plugins/${name}.wasm
    '';
  };
in
  zellij-autolock
