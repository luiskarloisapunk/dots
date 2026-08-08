{ ... }:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/desktop.nix
    ../../modules/home/packages.nix
    ../../modules/home/caelestia.nix
    ../../modules/home/spicetify.nix
    ../../modules/home/laptop.nix
  ];

  home.username = "lk";
  home.homeDirectory = "/home/lk";
  home.stateVersion = "26.05";
}
