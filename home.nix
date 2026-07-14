{config, pkgs,...}:

let 
  dotfiles = "${config.home.homeDirectory}/.dots/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    mango= "mango";
    nvim= "nvim";
    foot= "foot";
    quickshell= "quickshell";
    hypr = "hypr";
    spicetify = "spicetify";
  };
in



{

  imports = [
    ./modules/caelestia.nix
    ./modules/spicetify.nix
  ];

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
    foot
    yazi
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
];

}
