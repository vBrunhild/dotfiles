{
  nix = {
    gc.automatic = false;

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
      cores = 2;
      max-jobs = 2;
      keep-going = true;
      log-lines = 20;
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      substituters = ["https://cache.nixos.org"];
    };
  };

  systemd.services.nix-daemon = {
    enable = true;
    environment.TMPDIR = "/var/tmp";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
}
