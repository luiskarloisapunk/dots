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
      # Captura rápida de un gasto personal al journal del año actual.
      # La tarjeta banamex:colegiatura NO es válida aquí — usa hlcol para eso.
      JOURNAL_DIR="${financeDir}"
      YEAR=$(date +%Y)
      JOURNAL_FILE="$JOURNAL_DIR/''${YEAR}.journal"
      DATE=$(date +%Y-%m-%d)

      if [[ $# -lt 3 ]]; then
        echo "Uso: hladd \"descripción\" monto categoria [cuenta_origen]"
        echo "  categoria:    comida:universidad | comida:super | transporte | materiales"
        echo "                tecnologia | salud | ropa | entretenimiento | fijos | varios"
        echo "  cuenta_origen: efectivo (default) | beca | ahorros | credito"
        echo ""
        echo "  Para pagos de colegiatura usa: hlcol"
        echo ""
        echo "Ejemplos:"
        echo "  hladd \"Tacos\" 60 comida:universidad"
        echo "  hladd \"Uber\" 85 transporte beca"
        exit 1
      fi

      DESC="$1"
      MONTO="$2"
      CATEGORIA="$3"
      ORIGEN="''${4:-efectivo}"

      if [[ "$ORIGEN" == "colegiatura" ]]; then
        echo "Error: banamex:colegiatura es exclusiva para pagos escolares."
        echo "Usa: hlcol \"descripción\" monto"
        exit 1
      fi

      case "$ORIGEN" in
        efectivo)        ORIGEN_CUENTA="assets:efectivo" ;;
        beca)            ORIGEN_CUENTA="assets:bancomer:beca" ;;
        ahorros)         ORIGEN_CUENTA="assets:bancomer:ahorros" ;;
        credito|crédito) ORIGEN_CUENTA="liabilities:credito" ;;
        *)               ORIGEN_CUENTA="assets:$ORIGEN" ;;
      esac

      cat >> "$JOURNAL_FILE" << ENTRY

$DATE * $DESC
    expenses:$CATEGORIA    $MONTO MXN
    $ORIGEN_CUENTA
ENTRY

      echo "Agregado: $DATE $DESC — MXN $MONTO en expenses:$CATEGORIA"
    '';
  };

  hlcol = pkgs.writeShellApplication {
    name = "hlcol";
    runtimeInputs = [ ];
    text = ''
      # Registra un pago de colegiatura desde banamex:colegiatura.
      # Uso: hlcol "descripción" monto
      JOURNAL_DIR="${financeDir}"
      YEAR=$(date +%Y)
      JOURNAL_FILE="$JOURNAL_DIR/''${YEAR}.journal"
      DATE=$(date +%Y-%m-%d)

      if [[ $# -lt 2 ]]; then
        echo "Uso: hlcol \"descripción\" monto"
        echo "Ejemplo: hlcol \"Colegiatura agosto\" 15000"
        exit 1
      fi

      DESC="$1"
      MONTO="$2"

      cat >> "$JOURNAL_FILE" << ENTRY

$DATE * $DESC
    expenses:colegiatura    $MONTO MXN
    assets:banamex:colegiatura
ENTRY

      echo "Registrado: $DATE $DESC — MXN $MONTO (colegiatura)"
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
    bashrcExtra = ''
      cpp() { g++ -std=c++11 -O2 -Wall "$1" -o /tmp/cpp_out && /tmp/cpp_out; }
    '';
    shellAliases = {
      culo   = "echo Come mierda, majadero";
      dots   = "cd ${config.home.homeDirectory}/.dots && nvim .";
      conf   = "cd ${dotfiles} && nvim .";
      nr     = "sudo nixos-rebuild switch --flake ~/.dots#$(hostname)";
      nrs    = "git -C ~/.dots pull --rebase && sudo nixos-rebuild switch --flake ~/.dots#$(hostname)";
      # hledger — finanzas
      hl     = "hledger";
      hlbal  = "hledger bal -M --tree not:assets:banamex:colegiatura not:equity";
      hlgasto = "hledger bal expenses -M --tree";
      hlrep  = "hledger is -M";
    };
  };

  home.packages = [ hladd hlcol ];

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
