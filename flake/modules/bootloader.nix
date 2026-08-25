{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };

    loader = {
      limine = {
        # Bootloader
        enable = true;
        secureBoot.enable = config.features.coding.enable;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
