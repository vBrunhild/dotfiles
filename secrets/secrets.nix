let
  keys = import ./keys.nix;
in {
  "aws-credentials.age".publicKeys = [keys.users.brunhild keys.systems.laptop];
  "github-token.age".publicKeys = [keys.users.brunhild keys.systems.laptop];
  "rclone-config.age".publicKeys = [keys.users.brunhild keys.systems.laptop];
}
