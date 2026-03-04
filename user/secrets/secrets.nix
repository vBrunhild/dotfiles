let
  keys = import ./keys.nix;
in {
  "aws-credentials.age".publicKeys = [keys.users.brunhild keys.systems.laptop];
}
