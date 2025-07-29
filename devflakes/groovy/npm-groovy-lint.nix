{pkgs, ...}: let
  inherit (pkgs) buildNpmPackage fetchFromGitHub;
  npm-groovy-lint = buildNpmPackage rec {
    pname = "npm-groovy-lint";
    version = "15.2.1";

    src = fetchFromGitHub {
      owner = "nvuillam";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-qVoebuUKEi7A+KcqYzGFI/39cvLeQhcoSiB31hXrrD0=";
    };

    npmDepsHash = "sha256-Lvv+G2T0PUPiyphd71f4uDS1eBDqOAyACBfU0D365n0=";
  };
in
  npm-groovy-lint
