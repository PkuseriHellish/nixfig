{
  description = "NixOS configeee";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

    blender36 = pkgs.stdenv.mkDerivation rec {
  pname = "blender-bin";
  version = "3.6.22";

  src = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.6/blender-3.6.22-linux-x64.tar.xz";
    hash = "sha256-WVPIf21INgUGGng5dYUnxny4ITjQ01kPktjHarx1dgA=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.patchelf
  ];

  installPhase = ''
    mkdir -p $out/libexec
    cd $out/libexec

    tar xf $src
    mv blender-* blender

    mkdir -p $out/bin
    mkdir -p $out/share/applications

    cp blender/blender.desktop $out/share/applications/

    makeWrapper $out/libexec/blender/blender $out/bin/blender \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
        pkgs.wayland
        pkgs.libdecor
        pkgs.libx11
        pkgs.libxi
        pkgs.libxxf86vm
        pkgs.libxfixes
        pkgs.libxrender
        pkgs.libxkbcommon
        pkgs.libGL
        pkgs.libglvnd
        pkgs.numactl
        pkgs.SDL2
        pkgs.libdrm
        pkgs.ocl-icd
        pkgs.stdenv.cc.cc.lib
        pkgs.openal
        pkgs.libsm
        pkgs.libice
        pkgs.zlib
        pkgs.libxt
        pkgs.zstd
        pkgs.libxcrypt
        pkgs.ncurses
        pkgs.ocl-icd
      ]}:/run/opengl-driver/lib

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/libexec/blender/blender

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/libexec/blender/3.6/python/bin/python3.10
  '';

  meta.mainProgram = "blender";
};

    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager

          ({ ... }: {
            environment.systemPackages = [
              blender36
            ];
          })
        ];
      };
    };
}