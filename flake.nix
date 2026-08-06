{
  description = "NixOS configeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-blender36.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-blender36, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        #poopgpt you better be right and that i get my blender 3.6
        ({ pkgs, ... }: {
          environment.systemPackages = [
            (import nixpkgs-blender36 {
              system = "x86_64-linux";
              config.allowUnfree = true;
            }).blender
          ];
        })
      ];
    };
  };
}