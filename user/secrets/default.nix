{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  age = {
    identityPaths = [
      "${homeDir}/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets = {
      aws-credentials = {
        file = ./files/aws-credentials.age;
        path = "${homeDir}/.aws/credentials";
      };
    };
  };
}
