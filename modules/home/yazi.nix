{ config, pkgs, lib, ... }:

let
  kdeconnectSend = pkgs.yaziPlugins.mkYaziPlugin {
    pname = "kdeconnect-send.yazi";
    version = "0-unstable-2026-05-12";
    src = pkgs.fetchFromGitHub {
      owner = "Deepak22903";
      repo = "kdeconnect-send.yazi";
      rev = "06674d12779bd7243793bb29cf0a5f1273467d3d";
      hash = "sha256-pfvmjQw8m/0yUdCK+TW0mvZDWAfyx1skmPjvWSTvk00=";
    };
    meta.description = "Send selected files via KDE Connect from Yazi";
  };

  omniTrash = pkgs.yaziPlugins.mkYaziPlugin {
    pname = "omni-trash.yazi";
    version = "0-unstable-2026-06-10";
    src = pkgs.fetchFromGitHub {
      owner = "goon";
      repo = "omni-trash.yazi";
      rev = "3c2a9923673e0552a093afc4122473df1d427a93";
      hash = "sha256-heqqEWzJCoNt3CIJAEaWfqUX4J9BfVEw3OsU7Xjc17M=";
    };
    meta.description = "Manage trash across all drives from Yazi";
  };

  pluginStore = {
    "clipboard.yazi"       = pkgs.yaziPlugins.clipboard;
    "mount.yazi"           = pkgs.yaziPlugins.mount;
    "compress.yazi"        = pkgs.yaziPlugins.compress;
    "convert.yazi"         = pkgs.yaziPlugins.convert;
    "drag.yazi"            = pkgs.yaziPlugins.drag;
    "duckdb.yazi"          = pkgs.yaziPlugins.duckdb;
    "kdeconnect-send.yazi" = kdeconnectSend;
    "omni-trash.yazi"      = omniTrash;
  };

  pluginsDir = "${config.home.homeDirectory}/.dots/config/yazi/plugins";
in
{
  home.packages = with pkgs; [
    ripdrag                      # drag.yazi: drag-and-drop backend
    duckdb                       # duckdb.yazi: data file preview
    wl-clipboard                 # clipboard.yazi: Wayland clipboard sync
    kdePackages.kdeconnect-kde   # kdeconnect-send.yazi: send files via KDE Connect
  ];

  home.activation.yaziPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${pluginsDir}"
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: pkg: ''
      ln -sfn "${pkg}" "${pluginsDir}/${name}"
    '') pluginStore)}
  '';
}
