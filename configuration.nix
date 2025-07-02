{ ... }:

{
	imports = [
		<nixos-wsl/modules>
		./packages.nix
		./users.nix
		./envars.nix
		./git.nix
	];

	wsl.enable = true;
	wsl.defaultUser = "brunhild";
	system.stateVersion = "24.11";
}
