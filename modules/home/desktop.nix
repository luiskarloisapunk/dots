{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    extraConfig = ''
      include ~/.local/state/caelestia/theme/kitty.conf

      window_padding_width 15
      hide_window_decorations yes
      confirm_os_window_close 0
      background_opacity 0.8
    '';
  };

  home.pointerCursor = let
    hackneyedDark = pkgs.hackneyed.overrideAttrs (old: {
      makeFlags = (old.makeFlags or []) ++ [ "DARK_THEME=1" ];
    });
  in {
    gtk.enable = true;
    x11.enable = true;
    name = "Hackneyed-Dark";
    package = hackneyedDark;
    size = 24;
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager";
    genericName = "File Manager";
    exec = "kitty --class yazi -e yazi %u";
    icon = "yazi";
    terminal = false;
    categories = [ "System" "FileTools" "FileManager" "ConsoleOnly" ];
    mimeType = [ "inode/directory" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = [ "yazi.desktop" ];
  };
}
