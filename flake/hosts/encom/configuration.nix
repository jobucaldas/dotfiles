# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen2

    ./hardware-configuration.nix
    ../../modules/general.nix
    ../../modules/apps/gaming.nix
    ../../modules/apps/coding.nix
  ];

  features = {
    desktop = "mango";
    gamescopeSession.enable = false;
  };

  networking.hostName = "encom"; # Define your hostname

  boot = {
    loader = {
      limine = {
        # Bootloader
        enable = true;
        secureBoot.enable = true;
      };

      efi.canTouchEfiVariables = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."jobu" = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "podman"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
