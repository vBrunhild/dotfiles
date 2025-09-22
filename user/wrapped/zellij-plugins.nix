{pkgs, ...}: let
  inherit (pkgs) fetchurl;
  inherit (pkgs.stdenv) mkDerivation;

  zellij-autolock = mkDerivation rec {
    pname = "zellij-autolock";
    version = "0.2.2";

    src = fetchurl {
      url = "https://github.com/fresh2dev/zellij-autolock/releases/download/${version}/zellij-autolock.wasm";
      sha256 = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/zellij-plugins
      cp $src $out/share/zellij-plugins/zellij-autolock.wasm
    '';
  };

  zjstatus = mkDerivation rec {
    pname = "zjstatus";
    version = "0.21.1";

    src = fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjstatus.wasm";
      sha256 = "sha256-3BmCogjCf2aHHmmBFFj7savbFeKGYv3bE2tXXWVkrho=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/zellij-plugins
      cp $src $out/share/zellij-plugins/zjstatus.wasm
    '';
  };
in
  pkgs.symlinkJoin {
    name = "zellij-plugins";
    paths = [
      zellij-autolock
      zjstatus
    ];
  }
