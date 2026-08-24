{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./apps/coding.nix
    ./apps/gaming.nix
  ];

  # Feature flag to choose the default desktop
  options.features.defaultDesktop = lib.mkOption {
    type = lib.types.enum [
      "mango"
      "niri"
      "gnome"
    ];
    default = "mango";

    description = "Desktop environment/window manager";
  };

  # Feature flag to enable coding stuff
  options.features.coding.enable = lib.mkEnableOption "coding apps and tools";

  config = {
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

      xone.enable = true;
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

    xdg.portal.enable = true;

    networking = {
      wireless.enable = true; # Enables wireless support via wpa_supplicant.

      networkmanager.enable = true;

      # Configure network proxy if necessary
      # proxy.default = "http://user:password@proxy:port/";
      # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      firewall = {
        # Open ports in the firewall.
        allowedTCPPorts = [ 57621 ]; # Spotifyd port
        allowedUDPPorts = [ 5353 ];  # Spotifyd port

        # Or disable the firewall altogether.
        # enable = false;
      };
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;

      pam.services = {
        swaylock = { };
        login.enableGnomeKeyring = true;
      };
    };

    # Set your time zone.
    time.timeZone = "America/Sao_Paulo";

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
        monaspace
        # jetbrains-mono
      ];

      fontDir.enable = true;
    };

    environment = {
      pathsToLink = [
        "/share/oh-my-zsh"
        "/share/zsh"
        "/share/zsh-syntax-highlighting"
      ];

      systemPackages = with pkgs; [
        ## System Utilities
        git
        zsh
        oh-my-zsh
        zsh-autosuggestions
        zsh-syntax-highlighting
        tmux
        nixfmt
        nil
        wget
        sbctl
        ffmpeg
        jq
        curl
        p7zip
        fuzzel
        zenity
        htop
        ripgrep
        nerd-fonts.fira-code

        ## CLI
        git
        mpv
        stow
        wiremix
        jfbview
        swayimg
        unzip
        rclone
        rsync
        pfetch-rs
        imagemagick
        spotify-player
        findutils
        python3

        ## Apps
        anki
        kodi
        kitty
        kitty.terminfo
        vesktop
        inputs.helium.packages.${stdenv.hostPlatform.system}.default

        ## Desktop
        mako
        quickshell
        swaylock
        swayidle
        xwayland-satellite
        libsForQt5.qt5ct
        kdePackages.qt6ct
        kdePackages.qtstyleplugin-kvantum
        kdePackages.breeze
      ];

      etc."xdg/quickshell/shell.qml".text = ''
        import Quickshell

        ShellRoot {}
      '';
    };


    # Setup applications
    programs = {
      # Workaround to run apps that look for libraries directly
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          # Libraries needed for Fields of Mistria mod loader
          icu
          libice
          libsm
          libx11
          libxcursor
          libxext
          libxfixes
          libxi
          libxrandr
          libxrender
          libxtst
          libxkbcommon

          # Font stuff
          fontconfig
          freetype
        ];
      };

      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      zsh.enable = true;

      tmux = {
        enable = true;

        keyMode = "vi";

        plugins = with pkgs.tmuxPlugins; [
          cpu
          resurrect
          continuum
          yank
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
      appimage = {
        enable = true;
        binfmt = true;
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };
    };

    services = {
      xserver = {
        videoDrivers = [ "amdgpu" ];

        # Enable the X11 windowing system.
        enable = true;
        exportConfiguration = true;

        # Remove xterm
        desktopManager.xterm.enable = false;
        excludePackages = [ pkgs.xterm ];

        # Enable touchpad support (enabled default in most desktopManager).
        # libinput.enable = true;
      };

      upower.enable = true;

      # Enable CUPS to print documents.
      printing.enable = true;

      # Enable sound with pipewire.
      pulseaudio = {
        enable = false;
      };
      pipewire = {
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

      envfs = {
        enable = true;

        extraFallbackPathCommands = ''
          ln -s ${pkgs.systemd}/bin/systemctl $out/systemctl
          ln -s ${pkgs.python3}/bin/python3 $out/python3
        '';
      };

      flatpak = {
        enable = true;

        packages = [
          "it.mijorus.gearlever"
          "com.spotify.Client"
          "rocks.shy.VacuumTube"
          "net.ankiweb.Anki"
          "org.filezillaproject.Filezilla"
        ];
      };

      tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      spotifyd = {
        enable = true;
      };

      # Enable the OpenSSH daemon.
      openssh = {
        enable = true;

        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    };

    systemd = {
      # Keep NixOS service behavior; use config linked by Home Manager from repo.
      services.spotifyd.serviceConfig.ExecStart = lib.mkForce "${pkgs.spotifyd}/bin/spotifyd --no-daemon --cache-path /var/cache/spotifyd --config-path /home/jobu/.config/spotifyd/spotifyd.conf";

      # user.services.niri.enableDefaultPath = false;

      # Needed for swap to be treated correctly
      oomd.enable = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
