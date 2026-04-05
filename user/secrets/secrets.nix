let
  keys = import ./keys.nix;
in {
  "files/aws-credentials.age".publicKeys = [keys.users.brunhild keys.systems.laptop];
}
