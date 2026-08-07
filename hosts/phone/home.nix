{ pkgs, ... }:

# Configuración para Android via nix-on-droid.
# Solo incluye módulos CLI — sin desktop, caelestia ni spicetify.
{
  imports = [
    ../../modules/home/common.nix
  ];

  home.username = "nix-on-droid";
  home.homeDirectory = "/data/data/com.termux.nix/files/home";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    neovim
    fd
    ripgrep
    git
    hledger
  ];
}
