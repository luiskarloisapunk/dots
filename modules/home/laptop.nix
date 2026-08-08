{ lib, ... }:

{
  programs.caelestia.settings = {
    bar.status.showBattery = lib.mkForce true;
    osd.enableBrightness = lib.mkForce true;
    bar.scrollActions.brightness = lib.mkForce true;
  };

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NVD_BACKEND = "direct";
  };
}
