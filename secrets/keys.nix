let
  users = {
    brunhild = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAov1WMz0602zpjhINgrKSOdm0yFdE/JR+fCF0eEFCp3 brunomoretti100@gmail.com";
  };

  systems = {
    laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5fSH1j7SVNpW232j1dtJ0m7vxVdoYa7d+cjT8ZYsHb root@siegfried";
  };

  all =
    builtins.attrValues users
    ++ builtins.attrValues systems;
in {inherit users systems all;}
