{pkgs, ...}: let
  morpheus = pkgs.buildGoModule rec {
    pname = "morpheus";
    version = "1.0.5";
    src =
      pkgs.fetchFromGitHub {
        owner = "StafSis";
        repo = "Morpheus";
        rev = "v${version}";
        sha256 = "sha256-dlCbGeS7Jnnzm0+nb5s3BkRoM4kedFv0POzxUJfTTI0=";
      }
      + "/src";
    vendorHash = "sha256-lITCmT+hBfZS4BIxNsaQXuXmnJINy2Rf1OCTcgMvgw4=";
  };
in
  morpheus
