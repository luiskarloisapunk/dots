{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    max-jobs = "auto";
    cores = 0;
    http2 = false;
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    auto-optimise-store = true;
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  time.timeZone = "America/Monterrey";

  networking.networkmanager.enable = true;

  console.useXkbConfig = true;

  users.users.lk = {
    isNormalUser = true;
    extraGroups = [ "wheel" "opentabletdriver" ];
    packages = with pkgs; [ tree ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
  ];
}
