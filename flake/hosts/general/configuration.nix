{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };
  };

  hardware = {
    # Enable OpenGL/Vulkan
    graphics = {
      enable = true;
      enable32Bit = true; # Crucial for running 32-bit games (like Wine/Proton)
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    xpadneo.enable = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  zramSwap.enable = true;



  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

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
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      fira-code
      fira-code-symbols
      font-awesome
      # jetbrains-mono
      monaspace
    ];

    fontDir.enable = true;
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
