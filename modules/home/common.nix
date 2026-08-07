{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dots/config";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configDirs = {
    mango = "mango";
    nvim = "nvim";
    quickshell = "quickshell";
    hypr = "hypr";
    doom = "doom";
  };
in

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Luis Karlo";
      user.email = "luiskarlo@duck.com";
      init.defaultBranch = "main";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      culo = "echo Come mierda, majadero";
      dots = "cd ${config.home.homeDirectory}/.dots && nvim .";
      conf = "cd ${dotfiles} && nvim .";
      # $(hostname) matches the flake attribute name for each machine
      nr = "sudo nixos-rebuild switch --flake ~/.dots#$(hostname)";
    };
  };

  home.sessionVariables = {
    LEDGER_FILE = "${config.home.homeDirectory}/personal/finance/main.journal";
  };

  xdg.configFile = builtins.mapAttrs (_: subpath: {
    source = mkSymlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configDirs;

  home.activation.dirSkeleton = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Asegurando esqueleto de directorios..."
    ${lib.concatMapStrings (dir: "mkdir -p $HOME/${dir}\n") [
      "coco"
      "downloads"
      "academic"
      "projects"
      "library/books"
      "library/media"
      "library/datasets"
      "personal/id"
      "personal/academic"
      "personal/finance"
      "personal/health"
      "personal/legal"
    ]}
  '';
}
