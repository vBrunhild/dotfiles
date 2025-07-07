{ pkgs, ... }:

{
  nix = {
    gc.automatic = false;
    package = pkgs.lix;

    settings = {
      flake-registry = "/etc/nix/registry.json";
      auto-optimise-store = true;
      builders-use-substitutes = true;
      allowed-users = ["@wheel"];
      trusted-users = ["@wheel"];
      commit-lockfile-summary = "chore: Update flake.lock";
      accept-flake-config = true;
      keep-derivations = true;
      keep-outputs = true;
      warn-dirty = false;
      sandbox = true;
      max-jobs = "auto";
      keep-going = true;
      log-lines = 20;
      extra-experimental-features = ["flakes" "nix-command" "recursive-nix" "ca-derivations"];
      substituters = ["https://cache.nixos.org"];
    };
  };

  programs.nix-ld.enable = true;
  programs.nh = {
    enable = true;
    flake = "/home/brunhild/dev/dotfiles";
  };

  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  nixpkgs = {
    config = {
      allowUnfree = false;
      allowBroken = true;
    };
  };
}
