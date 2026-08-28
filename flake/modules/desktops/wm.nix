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
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs = {
    noctalia = {
      enable = true;

      # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
      recommendedServices.enable = true;
    };

    noctalia-greeter = {
      enable = true;

      # Optional configuration
      greeter-args = "";

      # Full declarative greeter.toml (overwritten on each activation).
      # See examples/greeter.toml for every key (appearance.palette, output, …).
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard = {
          layout = "br-abnt2";
        };
      };
    };

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
  };

  # programs = {

  # };

  environment = {
    sessionVariables = {
      # Let Qt apps load the qt5ct/qt6ct platform theme (Noctalia palette lives there).
      # NOTE: the variable is QT_QPA_PLATFORMTHEME — no underscore before THEME.
      # "QT_QPA_PLATFORM_THEME" is not read by Qt at all.
      QT_QPA_PLATFORMTHEME = "qt6ct;qt5ct";
    };

    systemPackages = with pkgs; [
      # Apps
      nemo

      # GTK theme referenced by Noctalia's theme sync (dconf gtk-theme).
      # Without it GTK apps silently fall back to default light Adwaita.
      adw-gtk3
    ];
  };

  # Gives GTK/GIO apps the dconf GSettings backend (GIO_EXTRA_MODULES) and
  # starts the dconf D-Bus service. Without it apps fall back to the keyfile
  # backend and never see Noctalia's gtk-theme/color-scheme settings.
  programs.dconf.enable = true;

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "noctalia-greeter-session -- --session niri";
          user = "greeter";
        };
      };
    };

    # displayManager = {
    #   sddm = {
    #     enable = true;

    #     theme = "${pkgs.where-is-my-sddm-theme}/share/sddm/themes/where_is_my_sddm_theme";

    #     wayland = {
    #       enable = true;
    #     };

    #     extraPackages = with pkgs; [
    #       where-is-my-sddm-theme
    #     ];
    #   };
    # };

    gnome.gnome-keyring.enable = true;
  };
}
