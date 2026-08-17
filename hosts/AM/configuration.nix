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
    devices."phone".id= "KVXRKPF-KPAYV5B-FGWYEYV-RZGCAIM-UMQ4OAS-AXGNYBJ-6QBOHW4-LTXUWA3";
    folders = {
      "/home/lk/coco"     = { id = "coco";     devices = [ "am" "phone" ]; };
      "/home/lk/personal" = { id = "personal"; devices = [ "am" "phone" ]; };
      "/home/lk/org"      = { id = "org";      devices = [ "am" ]; };
      "/home/lk/library"  = { id = "library";  devices = [ "am" ]; };
      "/home/lk/academic" = { id = "academic"; devices = [ "am" ]; };
      "/home/lk/projects" = { id = "projects"; devices = [ "am" ]; };
    };
  };

  system.stateVersion = "26.05";
}
