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
    builtins.concatStringsSep "" (map (c: lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString c))) [r g b]);

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

  mix = amount: hex: base: let
    a = hexToRgb hex;
    b = hexToRgb base;
    blend = x: y: builtins.floor (x * amount + y * (1 - amount) + 0.5);
  in
    "#"
    + rgbToHex {
      r = blend a.r b.r;
      g = blend a.g b.g;
      b = blend a.b b.b;
    };
in {
  inherit
    chunkString
    hexToRgb
    hexToRgbAlpha
    mix
    rgbAlpha
    rgbToHex
    ;
}
