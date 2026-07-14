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

  enabledCustomApps = with spicePkgs.apps; [
    marketplace
  ];
colorScheme = "custom"; 


 customColorScheme = {

   text                = "f4e5ae"; 
   subtext             = "b8ab79"; 
   main                = "090600";
   highlight           = "ffeeaa"; 
   misc                = "ffeeaa"; 
   notification        = "807548"; 
   notification-error  = "fe7453";
   shadow              = "000000";
   card                = "0c0900";    
   player              = "282336";   
   sidebar             = "040300";   
   main-elevated       = "0c0900";   
   highlight-elevated  = "0f0b00";    
   selected-row        = "f4e5ae";
   button              = "ffeeaa";
   button-active       = "ffeeaa";
   button-disabled     = "807548";       
   tab-active          = "0c0900";       

 };
  };






}
