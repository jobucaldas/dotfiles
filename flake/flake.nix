{
  description = "System flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    helium.url = "github:AlvaroParker/helium-nix";

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      deploy-rs,
      home-manager,
      nix-flatpak,
      jovian-nixos,
      helium,
      mangowm,
      noctalia,
      llm-agents,
      ...
    }@inputs:
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      nixosConfigurations = {
        # Laptop setup
        encom = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hosts/encom/configuration.nix
          ];
        };

        # Steam-machine like system
        sauron = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hosts/sauron/configuration.nix
          ];
        };
      };

      deploy.nodes = {
        encom = {
          hostname = "encom";
          profiles.system = {
            user = "root";
            sshUser = "deploy";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.encom;
          };
          address = "100.84.34.90";
        };
        sauron = {
          hostname = "sauron";
          profiles.system = {
            user = "root";
            sshUser = "deploy";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.sauron;
          };
          address = "100.86.114.87";
        };
      };
    };
}
