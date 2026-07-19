{ pkgs, ... }: {

  # 1. Dependencias externas necesarias para que los plugins tengan qué ejecutar
  home.packages = with pkgs; [
    wl-clipboard
    trash-cli
    coreutils
  ];

  # 2. Forzamos la estructura física para que Yazi "vea" los plugins sin ambigüedades
  home.file = {
    ".config/yazi/plugins/chmod.yazi".source       = "${pkgs.yaziPlugins.chmod}";
    ".config/yazi/plugins/smart-enter.yazi".source = "${pkgs.yaziPlugins.smart-enter}";
    ".config/yazi/plugins/full-border.yazi".source = "${pkgs.yaziPlugins.full-border}";
    ".config/yazi/plugins/duckdb.yazi".source      = "${pkgs.yaziPlugins.duckdb}";
    ".config/yazi/plugins/recycle-bin.yazi".source = "${pkgs.yaziPlugins.recycle-bin}";
    ".config/yazi/plugins/office.yazi".source      = "${pkgs.yaziPlugins.office}";
    ".config/yazi/plugins/mount.yazi".source       = "${pkgs.yaziPlugins.mount}";
    ".config/yazi/plugins/clipboard.yazi".source   = "${pkgs.yaziPlugins.clipboard}";
  };

  # 3. Configuración declarativa
  programs.yazi = {
    enable = true;

    # Inicialización obligatoria para que los plugins se registren en Lua
initLua = ''
      require("full-border"):setup {}
      require("smart-enter"):setup {}
    '';

    keymap = {
      manager.prepend_keymap = [
        { on = [ "c" "m" ]; run = "plugin chmod"; desc = "Chmod files"; }
        { on = [ "l" ]; run = "plugin smart-enter"; desc = "Enter directory or open file"; }
        { on = [ "R" "b" ]; run = "plugin recycle-bin"; desc = "Open recycle-bin"; }
        { on = [ "M" ]; run = "plugin mount"; desc = "Open mount"; }
        { on = [ "y" ]; run = ["yank" "plugin clipboard -- --action=copy" ]; desc = "Yank files"; }
        { on = [ "x" ]; run = [ "yank --cut" "plugin clipboard -- --action=copy" ]; desc = "Yank files (cut)"; }
        { on = [ "<C-p>" ]; run = ["plugin clipboard -- --action=paste" ]; desc = "Paste yanked files"; }
      ];
    };
  };
}
