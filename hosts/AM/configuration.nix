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
  boot.loader.timeout = 0;

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "systemd.show_status=auto"
  ];

  boot.initrd.systemd.enable = true;

  fileSystems."/".options = [ "noatime" ];

  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.settings.Manager.DefaultTimeoutStopSec = "5s";

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

  services.fprintd.enable = true;
  services.fwupd.enable = true;

  security.pam.services.ly.fprintAuth = false;

  system.stateVersion = "26.05";
}
