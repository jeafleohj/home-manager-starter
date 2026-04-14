{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Snapshot específico para MongoDB Compass 1.44.4 compatible con MongoDB 4.0
    nixpkgs-mongodb-compass.url = "github:nixos/nixpkgs/d209d800b7df2d4b05ea1266b14a47cba5da129b";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixpkgs-mongodb-compass,
      ...
    }:
    let
      system = builtins.currentSystem;
      pkgs = import nixpkgs {
        inherit system;
        overlays = overlays;
      };
      username = builtins.getEnv "USER";
      mongodbPkgs = import nixpkgs-mongodb-compass {
        inherit system;
        config.allowUnfree = true;
      };
      overlays = [
        (final: prev: {
          mongodb-compass = mongodbPkgs.mongodb-compass;
        })
      ];
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          {
            # Home Manager needs a bit of information about you and the paths it should
            # manage.
            home.username = username;
            home.homeDirectory = "/home/${username}";

            # This value determines the Home Manager release that your configuration is
            # compatible with. This helps avoid breakage when a new Home Manager release
            # introduces backwards incompatible changes.
            #
            # You should not change this value, even if you update Home Manager. If you do
            # want to update the value, then make sure to first check the Home Manager
            # release notes.
            home.stateVersion = "26.05"; # Please read the comment before changing.

            # Let Home Manager install and manage itself.
            programs.home-manager.enable = true;
          }
          ./modules
        ];

      };
    };
}
