{lib, ...}: let
  chunkString = size: string: let
    len = builtins.stringLength string;
    parser = offset:
      if offset >= len
      then []
      else [(builtins.substring offset size string)] ++ (parser (offset + size));
  in
    parser 0;

  hexToRgb = hex: let
    rgb =
      map
      (string: lib.fromHexString "0x${string}")
      (chunkString 2 (lib.removePrefix "#" hex));
  in {
    r = builtins.elemAt rgb 0;
    g = builtins.elemAt rgb 1;
    b = builtins.elemAt rgb 2;
  };

  rgbToHex = {
    r,
    g,
    b,
  }:
    builtins.concatStringsSep "" (map lib.toHexString [r g b]);

  # Build an rgba() string from a hex color plus an alpha channel (0-255).
  rgbAlpha = {
    r,
    g,
    b,
    alpha,
  }: "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";

  hexToRgbAlpha = alpha: hex: let
    rgb = hexToRgb hex;
  in
    rgbAlpha (rgb // {inherit alpha;});
in {
  inherit
    chunkString
    hexToRgb
    hexToRgbAlpha
    rgbAlpha
    rgbToHex
    ;
}
