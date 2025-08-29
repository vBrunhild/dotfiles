{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "ripgrep-wrapped";
  paths = [ pkgs.ripgrep ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild =
    # bash
    ''
      wrapProgram $out/bin/rg \
        --add-flags "--max-columns=150" \
        --add-flags "--max-columns-preview" \
        --add-flags "--hidden" \
        --add-flags "--glob=!.git/" \
        --add-flags "--smart-case" \
    '';
}
