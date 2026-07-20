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
  imports = [ ./hardware-configuration.nix ];

  #  stylix = {
  #    enable = true;

  #   image = pkgs.fetchurl {
  #     name = "scott.jpg";
  #     url = "https://drive.jobucaldas.com/s/MDyg4X6HCE8b9EL/download";
  #     hash = "sha256-xA1mEXUVh/kM03byH89IdGLDUxO4HvgvlVRQy+RGLkM=";
  #   };

  #   polarity = "dark";
  # };

  # Bootloader.
  boot.loader.limine = {
    enable = true;
    secureBoot.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth = {
    enable = true;
    theme = "bgrt";
    themePackages = with pkgs; [
      nixos-bgrt-plymouth
    ];
  };

  # Enable OpenGL/Vulkan
  hardware = {
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

  services.xserver.videoDrivers = [ "amdgpu" ];

  # Needed for swap to be treated correctly
  systemd.oomd.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  zramSwap.enable = true;

  networking.hostName = "encom"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

    fontDir.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.exportConfiguration = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  services.upower.enable = true;

  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  systemd.user.services.niri.enableDefaultPath = false;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,br";
    variant = "intl,thinkpad";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio = {
    enable = false;
  };
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

  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override {
        extraArgs = "-system-composer";
      };
    })
  ];

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
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.tmux = {
    enable = true;

    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      cpu
      resurrect
      continuum
      yank
      # tmux-powerline
      battery
      better-mouse-mode
      tokyo-night-tmux
    ];

    extraConfig = "
      set -g mouse on
      set -g xterm-keys on
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -as terminal-features ',xterm*:extkeys,tmux*:extkeys,screen*:extkeys'
      set -sg escape-time 10
    ";
  };

  # Install steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;

    # Enable Gamescope (the micro-compositor used on the Steam Deck)
    gamescopeSession.enable = true;

    protontricks.enable = true;
  };

  jovian = {
    decky-loader = {
      enable = true;
      user = "jobu";
      stateDir = "/home/jobu/.config/decky-loader";

      package = (pkgs.decky-loader.override {
        pnpm_9 = pkgs.pnpm_10;
      }).overrideAttrs (old: {
        pnpmDeps = pkgs.fetchPnpmDeps {
          fetcherVersion = 3;
          inherit (old) pname version src;
          postPatch = ''
            rm pnpm-workspace.yaml
          '';
          pnpm = pkgs.pnpm_10;
          sourceRoot = "${old.src.name}/frontend";
          hash = "sha256-X1L8JYG5hgYMmfg0aa8XhkRU6/oFrYTPiXDIyq77puE=";
        };
      });
    };
  };

  # Optimize system performance for gaming on demand
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Install firefox.
  # programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "kde" ]; # or "kde"
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  virtualisation.podman = {
    enable = true;

    # Create a "docker" alias so you can still type "docker run ..."
    dockerCompat = true;

    # DNS name resolution for containers
    defaultNetwork.settings.dns_enabled = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    quickshell
    wiremix
    jfbview
    filezilla
    rsync
    rclone
    sbctl
    nixfmt
    nil
    wget
    pfetch-rs
    podman-compose
    kitty
    curl
    fuzzel
    swaylock
    mako
    swayidle
    ffmpeg
    p7zip
    jq
    zenity
    xwayland-satellite
    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    nautilus
    inputs.helium.packages.${stdenv.hostPlatform.system}.default
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  services.envfs = {
    enable = true;

    extraFallbackPathCommands = ''
      ln -s ${pkgs.systemd}/bin/systemctl $out/systemctl
      ln -s ${pkgs.python3}/bin/python3 $out/python3
    '';
  };

  systemd.services.decky-loader.path = with pkgs; [
    systemd
    python3
  ];

  environment.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  environment.etc."xdg/quickshell/shell.qml".text = ''
    import Quickshell

    ShellRoot {}
  '';

  systemd.user.services.quickshell = {
    description = "Quickshell";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --no-duplicate";
      Restart = "on-failure";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 57621 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
