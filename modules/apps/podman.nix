{
  flake.modules.nixos.podman = {pkgs, ...}: {
    environment.systemPackages = [pkgs.docker-compose];

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
