{
	description= "AM";
   	inputs = {
		nixpkgs.url = "nixpkgs/release-26.05";
		home-manager ={
			url = "github:nix-community/home-manager/release-26.05";	
      			inputs.nixpkgs.follows = "nixpkgs";
		};
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
	  };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

	outputs = {self, nixpkgs, home-manager,mangowm,spicetify-nix,caelestia-shell,...}:{
		nixosConfigurations.AM = nixpkgs.lib.nixosSystem{
			system = "x86_64-linux";
			modules = [
				mangowm.nixosModules.mango
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager ={
						useGlobalPkgs = true;
						useUserPackages = true;
						users.lk = import ./home.nix;
            sharedModules = [
              spicetify-nix.homeManagerModules.spicetify
              caelestia-shell.homeManagerModules.default

            ];
            extraSpecialArgs = { inherit spicetify-nix; };
						backupFileExtension = "backup";
					};
				}
			];
		};


	};




}
