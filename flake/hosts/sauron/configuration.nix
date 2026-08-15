# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{  
  imports = [
    ./hardware-configuration.nix
    ../../modules/general.nix
    ../../modules/apps/gaming.nix
  ];

  features = {
    desktop = "gnome";
    gamescopeSession.enable = true;
  };

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "sauron"; # Define your hostname.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings.General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
      };
    };

    xone.enable = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  zramSwap.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    fira-code
    fira-code-symbols
    font-awesome
    jetbrains-mono
    monaspace
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    excludePackages = [ pkgs.xterm ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber = {
      enable = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."jobu" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      nix-refresh = "nix flake update --flake \${HOME}/Projects/dotfiles/flake";
      nix-test = "sudo nixos-rebuild test --flake \${HOME}/Projects/dotfiles/flake#$(hostname)";
      nix-update = "sudo nixos-rebuild switch --flake \${HOME}/Projects/dotfiles/flake#$(hostname)";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-clean = "nix store gc";
    };

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
      ];
      theme = "agnoster";
    };

    interactiveShellInit = ''
      pfetch
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    gamescopeSession.enable = true;
    protontricks.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "gnome";
      user = "jobu";
    };

    decky-loader = {
      enable = true;
      user = "jobu";
      stateDir = "/home/jobu/.config/decky-loader";
    };

    hardware = {
      has.amd.gpu = true;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    settings = {
      encoder = "vaapi";
      adapter_name = "/dev/dri/renderD128";
      csrf_allowed_origins = "https://192.168.15.122:47990,https://192.168.15.122";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    kitty.terminfo
    git
    findutils
    wget
    python3
    pfetch-rs
    curl
    jq
    zenity
    ffmpeg
    p7zip
    wiremix
    rsync
    rclone
    nil
    nixfmt
    sbctl
    protonplus
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
    inputs.helium.packages.${stdenv.hostPlatform.system}.default
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
