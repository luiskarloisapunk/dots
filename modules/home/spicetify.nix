{config, pkgs,spicetify-nix, ...}:

let
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in
{

  programs.spicetify = {
  enable = true;

  enabledExtensions = with spicePkgs.extensions; [
    adblockify
    hidePodcasts
    shuffle
  ];

#colorScheme = "custom"; 

#customColorScheme = {
#src = "${config.home.homeDirectory}/.local/state/caelestia/theme/color.ini";
#};
  };






}
