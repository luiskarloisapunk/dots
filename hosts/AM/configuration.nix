{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/syncthing.nix
  ];

  networking.hostName = "AM";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Reemplaza LAPTOP_DEVICE_ID con el ID real del laptop (ver http://localhost:8384 en el laptop)
  services.syncthing.settings = {
    devices."am".id = "LAPTOP_DEVICE_ID";
    folders = {
      "/home/lk/coco"     = { id = "coco";     devices = [ "am" ]; };
      "/home/lk/personal" = { id = "personal"; devices = [ "am" ]; };
      "/home/lk/org"      = { id = "org";      devices = [ "am" ]; };
      "/home/lk/library"  = { id = "library";  devices = [ "am" ]; };
    };
  };

  system.stateVersion = "26.05";
}
