{pkgs, ...}: let
  inherit (pkgs) callPackage;
in {
  usql = callPackage ./usql {};
}
