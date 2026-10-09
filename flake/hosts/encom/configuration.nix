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
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen2
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ../../modules/general.nix
    ../../modules/desktops/mango.nix

    ../../users/jobu/user.nix
  ];

  features = {
    defaultDesktop = "mango";
    gamescopeSession.enable = false;
    coding.enable = true;
    secureboot.enable = true;
  };

  # Offline voice dictation (xhisper UX + whisper-cpp Vulkan engine).
  nixrepo.dictation.enable = true;

  networking.hostName = "encom"; # Define your hostname

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };

    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        # plasma6Support = true;
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];

        settings = {
          globalOptions = {
            Behavior.ShareInputState = "All";

            "Hotkey/TriggerKeys" = {
              "0" = "Control+space";
            };
            "Hotkey/EnumerateGroupForwardKeys" = { };
            "Hotkey/EnumerateGroupBackwardKeys" = { };
          };

          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "br-thinkpad";
              DefaultIM = "keyboard-br-thinkpad";
            };
            "Groups/0/Items/0" = {
              Name = "keyboard-br-thinkpad";
              Layout = "";
            };
            # Keep layouts for the built-in and external ABNT2 keyboards
            "Groups/0/Items/1" = {
              Name = "keyboard-br";
              Layout = "";
            };
            "Groups/0/Items/2" = {
              Name = "mozc";
              Layout = "";
            };

            GroupOrder = {
              "0" = "Default";
            };
          };
        };
      };
    };
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  environment.etc."samba/smb.conf".text = ''
    [global]
    workgroup = WORKGROUP
    client min protocol = SMB2
    client max protocol = SMB3
  '';

  hardware.printers.ensurePrinters = [
    {
      name = "HP_Laserjet_1022";
      location = "Sala";
      description = "HP LaserJet 1022";
      deviceUri = "ipp://192.168.15.10:631/printers/HP_LaserJet_1022";
      model = "everywhere";
      ppdOptions.PageSize = "A4";
    }
  ];

  # Use the ThinkPad XKB layout in the console too
  console.useXkbConfig = true;

  services.xserver = {
    # Configure keymap in X11
    xkb = {
      layout = "br";
      variant = "thinkpad";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
