{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  coreutils = [
    "cat"
    "cp"
    "cut"
    "dirname"
    "echo"
    "env"
    "false"
    "head"
    "ls"
    "mkdir"
    "mktemp"
    "printf"
    "pwd"
    "readlink"
    "sleep"
    "sort"
    "tail"
    "test"
    "touch"
    "tr"
    "true"
    "uname"
    "wc"
    "which"
  ];

  selected-coreutils =
    pkgs.runCommand "pi-agent-coreutils" {
      nativeBuildInputs = [pkgs.coreutils];
    } ''
      mkdir -p $out/bin
      ${pkgs.lib.concatMapStrings (name: "ln -s ${pkgs.coreutils}/bin/${name} $out/bin/${name}\n") coreutils}
    '';
in [
  inputs.sem.packages.${system}.default
  pkgs.bash
  pkgs.bubblewrap
  pkgs.eza
  pkgs.git
  pkgs.gnugrep
  pkgs.jq
  pkgs.jujutsu
  pkgs.nodejs
  pkgs.ripgrep
  selected-coreutils
]
