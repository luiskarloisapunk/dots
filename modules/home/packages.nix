{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    emacs
    fd
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    (writeShellApplication {
      name = "ns";
      runtimeInputs = [ fzf nix-search-tv ];
      text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
    })
    awww
    quickshell
    prismlauncher
    vesktop
    jetbrains-mono
    noto-fonts
    (texlive.combine {
      inherit (texlive) scheme-full dvipng dvisvgm;
    })
    direnv
    trash-cli
    yazi
    hledger
    claude-code
    gamemode
  ];
}
