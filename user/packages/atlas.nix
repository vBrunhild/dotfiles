{
  stdenv,
  lib,
  dockerTools,
  autoPatchelfHook,
  jq,
  gnutar,
}: let
  version = "1.3.1";

  image = dockerTools.pullImage {
    imageName = "arigaio/atlas";
    imageDigest = "sha256:f4025903708e530c56426d7ebf2d680e08428beac28111d3edd98cf91a7081d9";
    sha256 = "sha256-z2kPNMECOhXjIgQmIx7WKGyevnV5e4wxmF5Qx8LxEME=";
    finalImageTag = "${version}-distroless";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    inherit version;
    pname = "atlas-non-community";
    src = image;

    dontUnpack = true;
    dontAutoPatchelf = true;
    nativeBuildInputs = [autoPatchelfHook jq gnutar];
    buildInputs = [stdenv.cc.cc.lib];

    buildPhase = ''
      runHook preBuild

      mkdir image extracted
      tar -xf $src -C image

      manifest=$(jq -r '.[0].Layers[]' image/manifest.json)
      for layer in $manifest; do
        tar -xf "image/$layer" -C extracted
      done

      atlas=extracted/atlas
      if [[ ! -f "$atlas" ]]; then
        echo "error: $atlas not found in image layers" >&2
        find extracted -maxdepth 4 -type f | head -50 >&2
        exit 1
      fi
      echo "found atlas at: $atlas" >&2
      chmod u+rwX "$atlas"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 "$atlas" $out/bin/atlas
      runHook postInstall
    '';

    postInstall = ''
      autoPatchelf $out/bin/atlas
    '';

    meta = with lib; {
      description = "Atlas schema management tool (non-community/Pro build)";
      homepage = "https://atlasgo.io";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      mainProgram = "atlas";
      platforms = ["x86_64-linux"];
    };
  })
