# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # === BOOT ===
  boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];
  console.keyMap = "us";

  # === DESKTOP ===
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true; # offer the Wayland Plasma session


  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "gtk";
  # Storage, auto-mounting & file manager services
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # thumbnails (Dolphin uses this too)

  security.polkit.enable = true;   
  programs.dconf.enable = true;    

  # === HARDWARE (Intel Haswell-ULT) ===
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };
  # === PACKAGES ===
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [

  home-manager #ayo sus!!
    # Archives & CLI utilities
    unrar
    zip
    unzip
    micro
    rsync
    ffmpeg
    gallery-dl
    yt-dlp

    mangohud
    # Applications
    kdePackages.filelight
    wineWow64Packages.staging
    winetricks
    nomacs
    vesktop
    firefox
    haruna
    vscodium
    qbittorrent
  ];
  
  services.flatpak.enable = true;
  
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    dejavu_fonts
    liberation_ttf
    nerd-fonts.jetbrains-mono
  ];

  services.printing.enable = true;

  # === AUDIO ===
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # === USERS ===
  users.users."mad" = {
    isNormalUser = true;
    description = "Mad";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # === HOME-MANAGER ===
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.mad = { pkgs, ... }: {
    home.stateVersion = "26.05";

    # User-scoped packages (things you don't want system-wide)
    home.packages = with pkgs; [
    # ...
    ];
    # add the git here
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user.name = "Mad";
        user.email = "187168704+PkuseriHellish@users.noreply.github.com";
        init.defaultBranch = "main";
      };
    };
    programs.bash = {
      enable = true;

      shellAliases = {
        nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
        
        # Fixed: Updates the lockfile and instantly stages it so Nix commands recognize it
        nix-update = "sudo nix flake update --flake /etc/nixos && git -C /etc/nixos add /etc/nixos/flake.lock && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
        
        # Safely optimizes, rebuilds via absolute path, and cleans up older configurations
        nix-whynot = "sudo nix store optimise && sudo nixos-rebuild switch --flake /etc/nixos#nixos && sudo nix-collect-garbage --delete-older-than 7d";
      };
    };

    # Let home-manager manage itself
    programs.home-manager.enable = true;
  };

  # === NIX ===
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "26.05";
}
