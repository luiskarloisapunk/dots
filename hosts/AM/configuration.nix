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

  services.syncthing.settings = {
    devices."am".id = "ERR3JLQ-4PZGOEB-OFRIT4K-A6HIHDM-QLVEQ5X-D5N5Q6C-7KD7EBO-GT3NYQT";
    folders = {
      "/home/lk/coco"     = { id = "coco";     devices = [ "am" ]; };
      "/home/lk/personal" = { id = "personal"; devices = [ "am" ]; };
      "/home/lk/org"      = { id = "org";      devices = [ "am" ]; };
      "/home/lk/library"  = { id = "library";  devices = [ "am" ]; };
    };
  };

  system.stateVersion = "26.05";
}
