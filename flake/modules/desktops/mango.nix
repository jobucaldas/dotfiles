{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.mangowm.nixosModules.mango
    ./wm.nix
  ];

  # Setup applications
  programs = {
    mango.enable = true;
  };
}