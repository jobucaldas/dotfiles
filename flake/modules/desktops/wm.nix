{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  programs.noctalia = {
    enable = true;

    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  # programs = {
  #   dms-shell = {
  #     enable = true;

  #     systemd = {
  #       enable = true;           # Systemd service for auto-start
  #       restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
  #     };

  #     # Core features
  #     enableSystemMonitoring = true; # System monitoring widgets (dgop)
  #     enableVPN = true;              # VPN management widget
  #     enableDynamicTheming = true;   # Wallpaper-based theming (matugen)
  #     enableAudioWavelength = true;  # Audio visualizer (cava)
  #     enableCalendarEvents = true;   # Calendar integration (khal)
  #     enableClipboardPaste = true;   # Pasting from the clipboard history (wtype)
  #   };
  # };

  services = {
    #  greetd = {
    #    enable = true;
    #    settings = {
    #      default_session = {
    #        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd ${config.programs.niri.package}/bin/niri-session";
    #        user = "greeter";
    #      };
    #    };
    #  };

    displayManager = {
      sddm = {
        enable = true;

        theme = "${pkgs.where-is-my-sddm-theme}/share/sddm/themes/where_is_my_sddm_theme";

        wayland = {
          enable = true;
        };

        extraPackages = with pkgs; [
          where-is-my-sddm-theme
        ];
      };
    };

    gnome.gnome-keyring.enable = true;
  };
}