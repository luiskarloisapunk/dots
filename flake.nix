{
  description = "Dotfiles — NixOS (AM, am) + nix-on-droid (phone)";

  inputs = {
    nixpkgs.url = "nixpkgs/release-26.05";

    home-manager = {
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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-on-droid usa su propio nixpkgs (no sigue 26.05 aún)
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, mangowm, spicetify-nix, caelestia-shell, nix-on-droid, zen-browser, nur, ... }:
  let
    sharedHomeModules = [
      spicetify-nix.homeManagerModules.spicetify
      caelestia-shell.homeManagerModules.default
    ];

    sharedArgs = { inherit spicetify-nix zen-browser; };

    mkNixosHost = { hostname, system ? "x86_64-linux" }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          mangowm.nixosModules.mango
          { nixpkgs.overlays = [ nur.overlays.default ]; }
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lk = import ./hosts/${hostname}/home.nix;
              sharedModules = sharedHomeModules;
              extraSpecialArgs = sharedArgs;
              backupFileExtension = "backup";
            };
          }
        ];
      };
  in
  {
    nixosConfigurations = {
      AM = mkNixosHost { hostname = "AM"; };
      am = mkNixosHost { hostname = "am"; };
    };

    # Android via nix-on-droid (instalar desde F-Droid: Nix-on-Droid)
    # Descomentar cuando el teléfono esté configurado:
    # nixOnDroidConfigurations.phone = nix-on-droid.lib.nixOnDroidConfiguration {
    #   pkgs = import nix-on-droid.inputs.nixpkgs { system = "aarch64-linux"; };
    #   modules = [ ./hosts/phone/home.nix ];
    #   extraSpecialArgs = sharedArgs;
    # };
  };
}
