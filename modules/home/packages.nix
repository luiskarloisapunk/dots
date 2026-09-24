{ pkgs, zen-browser, inputs, ... }:

{
  imports = [ inputs.areofyl-fetch.homeManagerModules.default ];

  programs.fetch = {
    enable = true;
    labelColor = "red";
    info = [
      "os"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "wm"
      "theme"
      "icons"
      "font"
      "terminal"
      "cpu"
      "gpu"
      "memory"
      "swap"
      "disk"
      "ip"
      "locale"
      "colors"
    ];
    size = 4.0;
    speed = 1.0;
    spin = "xy";
    extraConfig = "futureOptionFloat = 1.0";
  };

  programs.vscodium = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
      ms-python.python
    ];
  };

  home.packages = with pkgs; [
    clang-tools
    neovim
    emacs-pgtk
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
    grim
    slurp
    cliphist
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
    udisks
    rnote
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    localsend
    zoom-us
    foliate
    libreoffice
    (writeShellApplication {
      name = "pptx-to-pdf";
      runtimeInputs = [ libreoffice ];
      text = ''
        tmpdir=$(mktemp -d)
        for f in "$@"; do
          soffice --headless --convert-to pdf --outdir "$tmpdir" "$f"
          base=$(basename "''${f%.*}")
          zen "$tmpdir/$base.pdf" &
        done
      '';
    })
    bluetui
    fastfetch
  ];
}
