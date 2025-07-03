{ pkgs, ...  }:

{
  users.users.brunhild = {
    isNormalUser = true;
    description = "Default";
    extraGroups = [ "networkmanager" "wheel" "users" ];
    shell = pkgs.fish;
  };
}
