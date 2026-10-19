{pkgs, ...}: let
  claude-code = pkgs.claude-code.override {
    manifest = {
      version = "2.1.293";
      platforms = {
        "linux-x64" = {
          binary = "claude.zst";
          checksum = "sha256-JXhto0fDBkHcbFBzPQkNd8tUDxBaYa9+mJW1bjn+FqU=";
        };
      };
    };
  };
in {
  environment.systemPackages = [claude-code];
  home-manager.users.brunhild.imports = [./home.nix];
}
