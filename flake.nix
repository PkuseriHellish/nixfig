{
  description = "NixOS configeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    blender-bin.url = "github:edolstra/nix-warez?dir=blender";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, blender-bin, ... }:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit blender-bin; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        nixos-hardware.nixosModules.lenovo-thinkpad-t440s

        ({ blender-bin, pkgs, ... }: {
          environment.systemPackages = [
            blender-bin.packages.${pkgs.system}.blender_3_6
          ];
        })
      ];
    };
  };
}