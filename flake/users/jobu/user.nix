{ config, pkgs, lib, inputs, ... }:
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
    ] ++ lib.optional config.features.coding.enable "podman";
    packages = with pkgs; [ ];
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