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

  # Use the KDE portal for Plasma sessions (gtk portal kept as a fallback
  # for non-KDE apps; the gnome portal was dropped since it conflicts with
  # Plasma's own file pickers / screen-share / portal implementation)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde pkgs.xdg-desktop-portal-gtk ];
  };

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
    intel-media-driver   # Broadwell (2014)+ — T440s is Haswell (2013), so see note below
    intel-vaapi-driver    # for older Haswell-gen Intel iGPU (your T440s)
  ];
};
  # Force the legacy i965 VA-API driver, since iHD doesn't support Haswell
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "i965";
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
    wl-clipboard

    mangohud
    # Applications
    kdePackages.filelight
	wineWow64Packages.full
  blender
    prisimlauncher
    winetricks
    nomacs
    vesktop
    firefox
    aseprite # yay 42 minutes on my haswell
    ungoogled-chromium # incase if webstites hates firefox for some reason (why???)
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
        user.name = "Sop";
        user.email = "187168704+PkuseriHellish@users.noreply.github.com";
        init.defaultBranch = "main";
      };
    };
    
    programs.bash = {
      enable = true;

     shellAliases = {
  # Switch to the current config
  nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";

  # Activate without adding a boot entry — good for testing before committing
  nix-test = "sudo nixos-rebuild test --flake /etc/nixos#nixos";

  # Escape hatch if a switch goes bad
  nix-rollback = "sudo nixos-rebuild switch --rollback";

  # Update inputs, verify it actually builds, switch, THEN stage the lockfile
  nix-update = ''
    cd /etc/nixos &&
    nix flake update &&
    sudo nixos-rebuild build --flake .#nixos &&
    sudo nixos-rebuild switch --flake .#nixos &&
    git add flake.lock &&
    cd -
  '';

  # Dedupe store paths
  nix-optimise = "sudo nix store optimise";

  # GC old generations — run this deliberately, not glued to every rebuild
  nix-gc = "sudo nix-collect-garbage --delete-older-than 7d";
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
