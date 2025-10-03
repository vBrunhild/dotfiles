{pkgs, ...}: let
  laravel-ls = pkgs.buildGoModule {
    pname = "laravel-ls";
    version = "0.0.10";

    src = pkgs.fetchFromGithub {
      owner = "laravel-ls";
      repo = "laravel-ls";
      rev = "eb436836c478a4e676d63d6424a12bbca48b4774";
      hash = "";
    };

    vendorHash = "";
  };
in
  laravel-ls
