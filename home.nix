{config, pkgs,...}:

let 
  dotfiles = "${config.home.homeDirectory}/.dots/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    mango= "mango";
    nvim= "nvim";
    quickshell= "quickshell";
    hypr = "hypr";
    doom = "doom";
  };
in



{

  imports = [
    ./modules/caelestia.nix
    ./modules/spicetify.nix
    ./modules/systemfile.nix
    ./modules/yazi.nix
  ];

xdg.desktopEntries = {
    yazi = {
      name = "Yazi File Manager";
      genericName = "File Manager";
      exec = "kitty --class yazi -e yazi %u"; 
      icon = "yazi";
      terminal = false;
      categories = [ "System" "FileTools" "FileManager" "ConsoleOnly" ];
      mimeType = [ "inode/directory" ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
    };
  };


	home.username= "lk";
	home.homeDirectory = "/home/lk";
	programs.git= {
    enable = true;
    settings.user.name = "Luis Karlo";
    settings.user.email = "luiskarlo@duck.com";
    settings = {
      init.defaultBranch = "main";
    };
  };
	home.stateVersion = "26.05";
	programs.bash = {
		enable = true;
		shellAliases = {
			culo = "echo Come mierda, majadero";
      dots = "cd ${config.home.homeDirectory}/.dots && nvim .";
      conf = "cd ${dotfiles} && nvim .";
      nr   = "sudo nixos-rebuild switch --flake ~/.dots#AM";
		};
	};


  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

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

  home.file.".config/spicetify/Themes/Caelestia/color.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/state/caelestia/theme/color.ini";



  home.pointerCursor = let
    hackneyedDark = pkgs.hackneyed.overrideAttrs (oldAttrs: {
      makeFlags = (oldAttrs.makeFlags or []) ++ [ "DARK_THEME=1" ];
    });
  in {
    gtk.enable = true;
    x11.enable = true;
    name = "Hackneyed-Dark"; 
    
    package = hackneyedDark;
    size = 24;
  };
	home.packages = with pkgs; [
		neovim
    emacs
    fd
		ripgrep
		nil
		nixpkgs-fmt
		nodejs
		gcc
    (pkgs.writeShellApplication 
      {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
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
    libreoffice
  ];

}
