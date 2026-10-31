{
  description = "System flake";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Keep Nyx's own nixpkgs pin so its CachyOS kernels use the binary cache.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nixrepo = {
      url = "github:jobucaldas/nixrepo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    # Preserve upstream's package set for its Linux and Darwin builds.
    ai-usagebar.url = "github:akitaonrails/ai-usagebar/4a98814009f470a0d78a4c1ea24e939761d2ef40";

    t3code-release = {
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.1.6/t3-0.1.6-linux-x64.tar.gz";
      flake = false;
    };

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

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use OpenBot's own nixpkgs pin and release packaging.
    openbot.url = "github:nightly-labs/openbot";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      deploy-rs,
      home-manager,
      nix-flatpak,
      nixrepo,
      jovian-nixos,
      mangowm,
      noctalia,
      noctalia-greeter,
      llm-agents,
      disko,
      sops-nix,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

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

      deploy = {
        user = "root";
        sshUser = "deploy";
        remoteBuild = true;
        sshOpts = [
          "-o"
          "ConnectTimeout=20"
          "-o"
          "ConnectionAttempts=2"
        ];
        confirmTimeout = 120;
        nodes = {
          encom = {
            hostname = "encom";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.encom;
          };
          sauron = {
            hostname = "sauron";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.sauron;
          };
        };
      };
    };
}
