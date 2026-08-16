{
  description = "NixOS configeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware,  ... }:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        nixos-hardware.nixosModules.lenovo-thinkpad-t440s

       
      ];
    };
  };
}