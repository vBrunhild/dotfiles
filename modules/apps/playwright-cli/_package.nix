{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeBinaryWrapper,
  playwright-driver,
}:
buildNpmPackage (finalAttrs: {
  pname = "playwright-cli";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-80xzHvf7BHGvoKvMdkGeNUsUrpZrpw5eryuQM8NKT/E=";
  };

  npmDepsHash = "sha256-mGD7a/v1cx/xPGZo8nN3WA40mYGgF/KzMKiGbvUeX4E=";

  dontNpmBuild = true;

  nativeBuildInputs = [makeBinaryWrapper];

  # The vendored playwright expects browser revisions that rarely match the
  # nixpkgs bundle, so point it straight at the nixpkgs chromium executable.
  postFixup = ''
    chromium=$(echo ${playwright-driver.browsers}/chromium-*/chrome-linux*/chrome)
    wrapProgram $out/bin/playwright-cli \
      --set-default NO_UPDATE_NOTIFIER 1 \
      --set-default PLAYWRIGHT_BROWSERS_PATH ${playwright-driver.browsers} \
      --set-default PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS 1 \
      --set-default PLAYWRIGHT_MCP_BROWSER chromium \
      --set-default PLAYWRIGHT_MCP_EXECUTABLE_PATH "$chromium"
  '';

  meta = {
    description = "Playwright CLI for browser automation";
    homepage = "https://github.com/microsoft/playwright-cli";
    changelog = "https://github.com/microsoft/playwright-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
  };
})
