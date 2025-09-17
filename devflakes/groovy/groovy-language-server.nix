{
  pkgs,
  jre,
  ...
}: let
  inherit (pkgs) stdenv fetchFromGitHub makeWrapper;
  gradle = pkgs.gradle_8;

  groovy-language-server = stdenv.mkDerivation {
    pname = "groovy-language-server";
    version = "unstable-2024-02-01";

    src = fetchFromGitHub {
      owner = "GroovyLanguageServer";
      repo = "groovy-language-server";
      rev = "21f6d1f8d3d9b9ae27674dee0bb1aef7f983977a";
      sha256 = "sha256-sfXM/NtUQHjhMOntXYIs+FBKpcP6Pw3YwHPACQ0Td50=";
    };

    nativeBuildInputs = [gradle makeWrapper];

    mitmCache = gradle.fetchDeps {
      pkg = groovy-language-server;
      # update or regenerate this by running
      #  $(nix build .#groovy-language-server.mitmCache.updateScript --print-out-paths)
      data = ./deps.json;
    };

    gradleBuildTask = "shadowJar";
    doCheck = true;

    installPhase = ''
      mkdir -p $out/{bin,share/groovy-language-server}
      cp build/libs/source-all.jar $out/share/groovy-language-server/groovy-language-server-all.jar

      makeWrapper ${jre}/bin/java $out/bin/groovy-language-server \
        --add-flags "-jar $out/share/groovy-language-server/groovy-language-server-all.jar"
    '';
  };
in
  groovy-language-server
