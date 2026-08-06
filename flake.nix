{
  description = "NixOS configeee";

  inputs = {
    # Swap this for a stable release branch (e.g. nixos-25.11) once one
    # matching your stateVersion exists; unstable works fine either way.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        # home-manager.users.mad is defined directly inside configuration.nix,
        # since configuration.nix is just another module merged into this set.
      ];
    };
  };
}
