{pkgs, ...}: let
  deco = pkgs.buildGoModule rec {
    pname = "deco";
    version = "1.6.2";
    src =
      pkgs.fetchFromGitHub {
        owner = "StafSis";
        repo = "deco";
        rev = version;
        sha256 = "sha256-n7T/88WlE6yeUtHkgOUWnY73GmCVKxrs+Hu6JzRF57w=";
      }
      + "/src";
    vendorHash = "sha256-TMXRUVseQA5UVwNDdUPsSoaFMZrA8y2E05HFR1dakJ8=";
  };
in
  deco
