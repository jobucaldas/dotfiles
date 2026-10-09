{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users."jobu" = {
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ]
    ++ lib.optional config.features.coding.enable "podman";
    packages = with pkgs; [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMeizcZzKudDYpBMWPkLQwM4+u/7pdVrvlo21g0CLCz jobu@encom"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuygEjUj9IlwBBaidBhaW2ct4oOTL5NkOz2tFQv1yPJ jobu@encom"
    ];
  };

  # Import the Home Manager module
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit inputs;
    };

    # Define the user config
    users.jobu = import ./home-manager.nix;
  };
}
