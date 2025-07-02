{ config, pkgs, ... }:

{
	imports = [
		<nixos-wsl/modules>
		./packages.nix
		./envars.nix
		./users.nix
		./git.nix
		./helix.nix
	];

	wsl.enable = true;
	wsl.defaultUser = "brunhild";
	system.stateVersion = "24.11";
}
