{
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (pkgs) callPackage;
in {
  pi-agent = callPackage ./pi-agent {inherit inputs config;};
  usql = callPackage ./usql {};
}
