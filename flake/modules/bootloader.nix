{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [ inputs.chaotic.nixosModules.nyx-cache ];

  boot = {
    # Apply nixrepo's module fixes to Nyx's cached kernel package set.
    kernelPackages = lib.mkDefault (
      inputs.chaotic.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_cachyos.extend (
        lib.composeManyExtensions pkgs.kernelPackagesExtensions
      )
    );

    # Graphical boot splash
    plymouth = {
      enable = true;
      theme = "bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
      extraConfig = ''
        [Daemon]
        DeviceScale=1
      '';
    };

    # Enable "Silent boot". systemd stage 1 has no boot.initrd.verbose.
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    loader = {
      limine = {
        # Bootloader
        enable = true;
        secureBoot.enable = config.features.secureboot.enable;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
