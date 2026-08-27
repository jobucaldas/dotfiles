{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  boot = {
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

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

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
