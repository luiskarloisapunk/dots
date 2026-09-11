{ pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  boot.kernelParams = [ "quiet" "splash" "loglevel=0" "rd.udev.log_level=3" "udev.log_priority=3" "rd.systemd.show_status=false" ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  services.displayManager.ly = {
    enable = true;
    settings = {
      animate = true;
      animation = "doom";
      hide_borders = true;
      save = false;
      load = false;
    };
  };

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "compose:ralt";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = false;

  programs.hyprland.enable = true;

  environment.etc."hyprspace-path".text =
    "${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so\n";

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.mango.enable = true;

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

  security.wrappers.gsr-kms-server = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  programs.steam ={
    enable = true;
    extest.enable = true;
  };

  hardware.opentabletdriver.enable = true;

  services.flatpak.enable = true;

  virtualisation.libvirtd.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users.lk.extraGroups = [ "docker" ];
}
