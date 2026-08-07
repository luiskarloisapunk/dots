{ ... }:

# Syncthing sync service — enable per-host by importing this module.
# Configure devices and folders in hosts/<name>/configuration.nix via:
#   services.syncthing.settings.devices.<id> = { ... };
#   services.syncthing.settings.folders.<path> = { ... };
{
  services.syncthing = {
    enable = true;
    user = "lk";
    dataDir = "/home/lk";
    configDir = "/home/lk/.config/syncthing";
    openDefaultPorts = true;
  };
}
