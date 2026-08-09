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
    yazi = "yazi";
  };

  financeDir = "${config.home.homeDirectory}/personal/finance";

  hladd = pkgs.writeShellApplication {
    name = "hladd";
    runtimeInputs = [ ];
    text = ''
      # Captura rápida de un gasto al journal del año actual.
      # Uso: hladd "descripción" monto categoria [cuenta_origen]
      JOURNAL_DIR="${financeDir}"
      YEAR=$(date +%Y)
      JOURNAL_FILE="$JOURNAL_DIR/''${YEAR}.journal"
      DATE=$(date +%Y-%m-%d)

      if [[ $# -lt 3 ]]; then
        echo "Uso: hladd \"descripción\" monto categoria [cuenta_origen]"
        echo "  categoria: comida:universidad | comida:super | transporte | materiales"
        echo "             tecnologia | salud | ropa | entretenimiento | colegiatura | varios"
        echo "  cuenta_origen (default: efectivo)"
        echo ""
        echo "Ejemplos:"
        echo "  hladd \"Tacos\" 60 comida:universidad"
        echo "  hladd \"Uber\" 85 transporte banamex:beca"
        exit 1
      fi

      DESC="$1"
      MONTO="$2"
      CATEGORIA="$3"
      ORIGEN="''${4:-efectivo}"

      case "$ORIGEN" in
        efectivo)          ORIGEN_CUENTA="assets:efectivo" ;;
        beca)              ORIGEN_CUENTA="assets:banamex:beca" ;;
        ahorros)           ORIGEN_CUENTA="assets:banamex:ahorros" ;;
        colegiatura)       ORIGEN_CUENTA="assets:banamex:colegiatura" ;;
        credito|crédito)   ORIGEN_CUENTA="liabilities:credito" ;;
        *)                 ORIGEN_CUENTA="assets:$ORIGEN" ;;
      esac

      cat >> "$JOURNAL_FILE" << ENTRY

      $DATE * $DESC
          expenses:$CATEGORIA    $MONTO MXN
          $ORIGEN_CUENTA
      ENTRY

      echo "Agregado: $DATE $DESC — MXN $MONTO en expenses:$CATEGORIA"
    '';
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
      culo   = "echo Come mierda, majadero";
      dots   = "cd ${config.home.homeDirectory}/.dots && nvim .";
      conf   = "cd ${dotfiles} && nvim .";
      nr     = "sudo nixos-rebuild switch --flake ~/.dots#$(hostname)";
      nrs    = "git -C ~/.dots pull --rebase && sudo nixos-rebuild switch --flake ~/.dots#$(hostname)";
      # hledger — finanzas
      hl     = "hledger";
      hlbal  = "hledger bal -M --tree";
      hlgasto = "hledger bal expenses -M --tree";
      hlrep  = "hledger is -M";
    };
  };

  home.packages = [ hladd ];

  home.sessionVariables = {
    LEDGER_FILE = "${financeDir}/main.journal";
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
      "personal/finance/scripts"
      "personal/health"
      "personal/legal"
    ]}
  '';
}
