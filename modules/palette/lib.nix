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
in {
  inherit
    chunkString
    hexToRgb
    rgbToHex
    ;
}
