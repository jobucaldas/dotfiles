{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home = {
    # Metadata
    username = "jobu";
    homeDirectory = "/home/${config.home.username}";

    # User packages
    # These are installed only for this user.
    packages = with pkgs; [
      htop
      ripgrep
      imagemagick
      kubectl
      gearlever
      protonplus
      (heroic.override {
        extraPkgs =
          pkgs': with pkgs'; [
            gamescope
            gamemode
          ];
      })
      megacmd
      steamcmd
      steam-tui
      spotify
      nerd-fonts.fira-code
    ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      name = "Remus-White";
      size = 30;

      package = pkgs.runCommand "cursor-Remus-White" { } ''
        mkdir -p "$out/share/icons"
        ln -s ${
          pkgs.fetchzip {
            name = "Remus-White.zip";
            url = "https://drive.jobucaldas.com/s/yJAmpLwixGiwNSk/download";
            hash = "sha256-hq4adOjB0ViCpzmhm9tn74RX4VbgZVp+YFHz8apIgC8=";
            extension = "zip";
          }
        }/Remus-White "$out/share/icons/Remus-White"
      '';
    };

    # Environment Variables
    sessionVariables = {
      XCURSOR_THEME = "Remus-White";
      XCURSOR_SIZE = "30";
      EDITOR = "nvim";
      BROWSER = "helium";
      TERMINAL = "kitty";
    };
  };

  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };

    desktopEntries.feh-fit = {
      name = "Feh Fit";
      genericName = "Image Viewer";
      exec = "${pkgs.feh}/bin/feh --scale-down %F";
      terminal = false;
      categories = [
        "Graphics"
        "Viewer"
      ];
      mimeType = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
      ];
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "image/png" = "feh-fit.desktop";
        "image/jpeg" = "feh-fit.desktop";
        "image/gif" = "feh-fit.desktop";
        "image/webp" = "feh-fit.desktop";
        "image/bmp" = "feh-fit.desktop";
        "image/tiff" = "feh-fit.desktop";
      };
    };
  };

  services = {
    spotifyd = {
      enable = true;

      settings = {
        global = {
          autoplay = false;
          device_name = "encom spotifyd";
          zeroconf_port = 57621;
        };
      };
    };

    tailscale-systray = {
      enable = true;
      theme = "dark:nobg";
    };
  };

  # Program configuration (The "Manager" Part)

  programs.github-copilot-cli = {
    enable = true;

    package = pkgs.llm-agents.copilot-cli;
  };

  programs.pi-coding-agent = {
    enable = true;

    package = pkgs.llm-agents.pi;

    extraPackages = [
      pkgs.nodejs
      pkgs.bun
      pkgs.llm-agents.rtk
    ];

    settings = {
      packages = [
        "npm:@termdraw/pi"
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        # "npm:@juicesharp/rpiv-web-tools"
        # "npm:pi-smart-fetch"
        "npm:context-mode"
        "npm:pi-caveman"
        "npm:pi-rtk-optimizer"
        "npm:visual-explainer"
        # "npm:pi-cursor-sdk"
        "npm:pi-supergsd"
        "npm:@narumitw/pi-usage"
      ];
      retry = {
        enabled = true;
        maxRetries = 10;
      };
      theme = "dark";
    };
  };

  programs.mpv = {
    enable = true;

    config = {
      profile = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
      loop-file = "inf";
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      set -g xterm-keys on
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -as terminal-features ',xterm*:extkeys,tmux*:extkeys,screen*:extkeys'
      set -sg escape-time 10
    '';
  };

  programs.feh = {
    enable = true;
  };

  programs.spotify-player = {
    enable = true;

    settings = {
      theme = "dracula";
      client_port = 8080;
      login_redirect_uri = "http://127.0.0.1:8989/login";
      playback_format = ''
        {status} {track} • {artists} {liked}
        {album} • {genres}
        {metadata}
      '';
      playback_metadata_fields = [
        "repeat"
        "shuffle"
        "volume"
        "device"
      ];
      notify_timeout_in_secs = 0;
      notify_transient = false;
      tracks_playback_limit = 50;
      app_refresh_duration_in_ms = 32;
      playback_refresh_duration_in_ms = 0;
      page_size_in_rows = 20;
      play_icon = "▶";
      pause_icon = "▌▌";
      liked_icon = "♥";
      explicit_icon = "(E)";
      border_type = "Plain";
      progress_bar_type = "Rectangle";
      progress_bar_position = "Bottom";
      genre_num = 2;
      cover_img_pixels = 32;
      cover_img_length = 9;
      cover_img_width = 5;
      cover_img_scale = 1.0;
      enable_media_control = true;
      enable_streaming = "Always";
      enable_audio_visualization = true;
      enable_notify = true;
      enable_cover_image_cache = true;
      default_device = "encom spcli";
      notify_streaming_only = false;
      seek_duration_secs = 5;
      sort_artist_albums_by_type = false;
      volume_scroll_step = 5;
      enable_mouse_scroll_volume = true;

      notify_format = {
        summary = "{track} • {artists}";
        body = "{album}";
      };

      layout = {
        playback_window_position = "Top";
        playback_window_height = 6;

        library = {
          playlist_percent = 40;
          album_percent = 40;
        };
      };

      device = {
        name = "encom spcli";
        device_type = "speaker";
        volume = 70;
        bitrate = 320;
        audio_cache = true;
        normalization = false;
        autoplay = false;
      };
    };
  };

  programs.vesktop = {
    enable = true;

    settings = {
      appBadge = true;
      arRPC = true;
      checkUpdates = true;
      customTitleBar = false;
      disableMinSize = true;
      minimizeToTray = true;
      tray = true;
      splashBackground = "#000000";
      splashColor = "#ffffff";
      splashTheming = true;
      staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "canary";
    };
  };

  programs.ncspot = {
    enable = true;

    settings = {
      shuffle = true;
    };
  };

  programs.yazi = {
    enable = true;

    settings = {
      manager = {
        show_hidden = true;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "R" ];
          run = "refresh";
          desc = "Refresh current directory";
        }
      ];
    };

    plugins = {
      inherit (pkgs.yaziPlugins)
        diff
        convert
        drag
        ouch
        rich-preview
        mediainfo
        mime-ext
        git
        ;
    };
  };

  programs.quickshell = {
    enable = true;
  };

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      gcc
      gnumake
      unzip
      curl
      nodejs
      lua-language-server
      stylua
      shfmt
      awscli
      opentofu

      # Nix support
      nil
      nixfmt
      statix
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      vim.opt.number = true
      vim.opt.relativenumber = false

      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      local kitty_bg = "#000000"
      local kitty_surface = "#1f1a20"

      local minibase16_palette = {
        base00 = "#141218",
        base01 = "#1f1a20",
        base02 = "#2a2430",
        base03 = "#9d99a5",
        base04 = "#cac4cf",
        base05 = "#e6e0e9",
        base06 = "#f4efff",
        base07 = "#faf8ff",
        base08 = "#ff728f",
        base09 = "#ff9fb2",
        base0A = "#ffda72",
        base0B = "#7fff9a",
        base0C = "#d0bcff",
        base0D = "#bca5f2",
        base0E = "#ded0ff",
        base0F = "#4e3d76",
      }

      local function apply_kitty_background()
        local groups = {
          "Normal",
          "NormalNC",
          "SignColumn",
          "FoldColumn",
          "LineNr",
          "EndOfBuffer",
          "NvimTreeNormal",
          "NvimTreeNormalNC",
        }

        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, { bg = kitty_bg })
        end

        vim.api.nvim_set_hl(0, "NormalFloat", { bg = kitty_surface })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = kitty_surface })
        vim.api.nvim_set_hl(0, "CursorLine", { bg = kitty_surface })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_kitty_background,
      })

      local function load_minibase16()
        require("mini.base16").setup({
          palette = minibase16_palette,
        })
        apply_kitty_background()
      end

      local function force_line_numbers()
        vim.opt.number = true
        vim.opt.relativenumber = false

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          vim.wo[win].number = true
          vim.wo[win].relativenumber = false
        end
      end

      vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "BufWinEnter", "WinEnter" }, {
        callback = force_line_numbers,
      })

      apply_kitty_background()

      require("lazy").setup({
        spec = {
          -- LazyVim base distro
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          
          {
            "nvim-mini/mini.nvim",
            version = false,
            lazy = false,
            priority = 1000,
          },

          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = load_minibase16,
            },
          },

          -- Use nvim-cmp instead of LazyVim default blink.cmp
          { import = "lazyvim.plugins.extras.coding.nvim-cmp" },

          -- Nix: treesitter nix + nil_ls + nixfmt + statix
          { import = "lazyvim.plugins.extras.lang.nix" },

          -- GitHub Copilot
          { import = "lazyvim.plugins.extras.ai.copilot" },

          -- Nix provides LSPs/tools. Mason stays available, but no auto-install.
          {
            "mason-org/mason.nvim",
            opts = {
              ensure_installed = {},
            },
          },
          {
            "mason-org/mason-lspconfig.nvim",
            opts = {
              ensure_installed = {},
            },
          },
          {
            "neovim/nvim-lspconfig",
            opts = {
              servers = {
                ["*"] = {
                  mason = false,
                },
                nil_ls = {
                  mason = false,
                },
                lua_ls = {
                  mason = false,
                },
              },
            },
          },

          -- File sidebar
          {
            "nvim-tree/nvim-tree.lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            keys = {
              { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
              { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
            },
            opts = {
              view = {
                width = 32,
                side = "left",
              },
              renderer = {
                group_empty = true,
              },
              filters = {
                dotfiles = false,
              },
            },
          },
        },

        defaults = {
          lazy = false,
          version = false,
        },

        install = {
          colorscheme = { "tokyonight", "habamax" },
        },

        checker = {
          enabled = false,
        },
      })

      force_line_numbers()
    '';
  };

  # Git: Never manually edit .gitconfig again
  programs.git = {
    enable = true;

    settings = {
      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Zsh: Manage your shell environment
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      nix-refresh = "nix flake update --flake \${HOME}/Projects/dotfiles/flake";
      nix-test = "sudo nixos-rebuild test --flake \${HOME}/Projects/dotfiles/flake#$(hostname)";
      nix-update = "sudo nixos-rebuild switch --flake \${HOME}/Projects/dotfiles/flake#$(hostname)";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-clean = "nix store gc";
      spcli = "spotify_player";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kitty"
        "kubectl"
        "opentofu"
        "ssh"
      ];
      theme = "nanotech";
    };

    initContent = ''
      pfetch
    '';
  };

  # VS Code: Managing extensions and settings
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix # Nix syntax support
          dracula-theme.theme-dracula
        ];
        userSettings = {
          #  "editor.fontSize" = 14;
          #  "workbench.colorTheme" = "Dracula";
          "nix.enableLanguageServer" = true;
        };
      };
    };
  };

  programs.anki = {
    enable = true;
  };

  programs.kodi = {
    enable = true;
  };

  # State Version (Do not change)
  home.stateVersion = "26.05";
}
