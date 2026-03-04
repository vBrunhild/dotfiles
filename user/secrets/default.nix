{home, ...}: {
  age = {
    identityPaths = [
      "~/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets = {
      aws-credentials = {
        file = ./files/aws-credentials.age;
        path = "${home.homeDirectory}/.aws/credentials";
      };
    };
  };
}
