{
  description = "System flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Add Home Manager input
    home-manager.url = "github:nix-community/home-manager";

    # Critical: Force HM to use the same nixpkgs version as the system
    # to avoid downloading duplicate packages.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      helium,
      llm-agents,
      jovian-nixos,
      ...
    }@inputs:
    {

      nixosConfigurations = {
        encom = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hosts/encom/configuration.nix

            # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen2

            jovian-nixos.nixosModules.default

            {
              nixpkgs.overlays = [ llm-agents.overlays.shared-nixpkgs ];
            }

            # Import the Home Manager module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";

                extraSpecialArgs = {
                  inherit inputs;
                };

                # Define the user config
                users.jobu = import ./hosts/encom/home.nix;
              };
            }
          ];
        };

        sauron = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hosts/sauron/configuration.nix
            jovian-nixos.nixosModules.default

            # Import the Home Manager module
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.backupFileExtension = "backup";

            #   home-manager.extraSpecialArgs = {
            #     inherit inputs;
            #   };

            #   # Define the user config
            #   home-manager.users.jobu = import ./hosts/sauron/home.nix;
            # }
          ];
        };
      };
    };
}
