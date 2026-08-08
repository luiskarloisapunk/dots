{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/syncthing.nix
  ];

  networking.hostName = "am";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA Quadro 1000 — si hay problemas usa legacy_470 o legacy_390 (Fermi)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];

  system.stateVersion = "26.05";
}
