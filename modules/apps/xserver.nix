{
  flake.modules.nixos.xserver = {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "br";
        variant = "abnt2";
      };
    };
  };
}
