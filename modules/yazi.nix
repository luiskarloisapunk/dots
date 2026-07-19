
{ pkgs, ... }: {
  programs.yazi = {
    enable = true;

    # Declaratively add pre-packaged plugins
    plugins = {
      chmod = pkgs.yaziPlugins.chmod;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      full-border = pkgs.yaziPlugins.full-border;
      duckdb = pkgs.yaziPlugins.duckdb;
      omni-trash = pkgs.yaziPlugins.omni-trash;
      office = pkgs.yaziPlugins.office;
      mount = pkgs.yaziPlugins.mount;
      clipboard = pkgs.yaziPlugins.clipboard;
  
    };

    # Keymaps to trigger your plugins
    keymap = {
      manager.prepend_keymap = [
        { on = [ "c" "m" ]; run = "plugin chmod"; desc = "Chmod files"; }
        { on = [ "l" ]; run = "plugin smart-enter"; desc = "Enter directory or open file"; }
        { on = [ "R" ]; run = "plugin omni-trash"; desc = "Open Omni-Trash"; }
        { on = [ "M" ]; run = "plugin mount"; desc = "Open mount"; }
        { on = [ "y" ]; run = ["yank" "plugin clipboard -- --action=copy" ]; desc = "Yank files"; }
        { on = [ "x" ]; run = [ "yank --cut" "plugin clipboard -- --action=copy" ]; desc = "Yank files (cut)"; }
        { on = [ "<C-p>" ]; run = ["plugin clipboard -- --action=paste" ]; desc = "Paste yanked files"; }


      ];
    };

  };
}
