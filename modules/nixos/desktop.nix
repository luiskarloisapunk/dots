{ pkgs, ... }:

{
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

  environment.sessionVariables.HYPRSPACE_SO =
    "${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so";

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
}
