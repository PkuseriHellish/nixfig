{ pkgs, ... }:
{
  home.username = "mad";
  home.homeDirectory = "/home/mad";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # anything from your old home.packages
  ];

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
      nix-rebuild  = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      nix-test     = "sudo nixos-rebuild test --flake /etc/nixos#nixos";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-update   = ''
        cd /etc/nixos &&
        nix flake update &&
        sudo nixos-rebuild build --flake .#nixos &&
        sudo nixos-rebuild switch --flake .#nixos &&
        git add flake.lock &&
        cd -
      '';
      nix-optimise = "sudo nix store optimise";
      nix-gc       = "sudo nix-collect-garbage --delete-older-than 7d";
      hm-switch    = "home-manager switch --flake /etc/nixos#mad";
    };
  };

  programs.home-manager.enable = true;
}