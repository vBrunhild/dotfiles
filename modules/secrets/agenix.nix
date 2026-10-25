{
  config,
  inputs,
  ...
}: let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
  secrets = ../../secrets;
in {
  flake.modules.nixos.agenix = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home-manager.users.${username}.imports = [hm.agenix];
  };

  flake.modules.homeManager.agenix = {config, ...}: let
    homeDir = config.home.homeDirectory;
  in {
    imports = [inputs.agenix.homeManagerModules.default];

    age = {
      identityPaths = [
        "${homeDir}/.ssh/id_ed25519"
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      secrets = {
        aws-credentials = {
          file = secrets + "/aws-credentials.age";
          path = "${homeDir}/.aws/credentials";
        };

        github-token = {
          file = secrets + "/github-token.age";
        };

        rclone-config = {
          file = secrets + "/rclone-config.age";
          path = "${homeDir}/.config/rclone/rclone.conf";
        };
      };
    };
  };
}
