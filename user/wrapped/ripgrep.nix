{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "ripgrep-wrapped";
  paths = [ pkgs.ripgrep ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild =
    # bash
    ''
      wrapProgram $out/bin/rg \
        --max-columns=150 \
        --max-columns-preview \
        --add-flags "--hidden" \
        --add-flags "--glob=!.git/" \
        --add-flags "--smart-case" \
    '';
}
