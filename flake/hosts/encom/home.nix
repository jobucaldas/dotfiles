{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  dotfilesRoot = "${config.home.homeDirectory}/Projects/dotfiles/config";
  outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/${path}";
in
{
  home = {
    # Metadata
    username = "jobu";
    homeDirectory = "/home/${config.home.username}";

    file = {
      ".zprofile".source = outOfStore "zsh/.zprofile";
      ".zshenv".source = outOfStore "zsh/.zshenv";
      ".zshrc".source = outOfStore "zsh/.zshrc";
      ".oh-my-zsh/custom" = {
        source = outOfStore "zsh/.oh-my-zsh/custom";
        recursive = true;
      };
    };

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
  };

  xdg = {
    # Keep config editable in repository. Home Manager creates links only.
    configFile = {
      "DankMaterialShell" = {
        source = outOfStore "dms/.config/DankMaterialShell";
        recursive = true;
      };
      "git" = {
        source = outOfStore "git/.config/git";
        recursive = true;
      };
      "kitty" = {
        source = outOfStore "kitty/.config/kitty";
        recursive = true;
      };
      "mango" = {
        source = outOfStore "mango/.config/mango";
        recursive = true;
      };
      "mpv" = {
        source = outOfStore "mpv/.config/mpv";
        recursive = true;
      };
      "niri" = {
        source = outOfStore "niri/.config/niri";
        recursive = true;
      };
      "nvim" = {
        source = outOfStore "vi/.config/nvim";
        recursive = true;
      };
      "spotifyd" = {
        source = outOfStore "spotifyd/.config/spotifyd";
        recursive = true;
      };
      "spotify-player" = {
        source = outOfStore "spotify-player/.config/spotify-player";
        recursive = true;
      };
      "tmux" = {
        source = outOfStore "tmux/.config/tmux";
        recursive = true;
      };

      # Link only intentional Vesktop config. Runtime data stays in ~/.config/vesktop.
      "vesktop/settings.json".source = outOfStore "vesktop/.config/vesktop/settings.json";
      "vesktop/settings/settings.json".source = outOfStore "vesktop/.config/vesktop/settings/settings.json";
      "vesktop/settings/quickCss.css".source = outOfStore "vesktop/.config/vesktop/settings/quickCss.css";
      "vesktop/themes/dank-discord.css".source = outOfStore "vesktop/.config/vesktop/themes/dank-discord.css";
      "yazi/keymap.toml".source = outOfStore "yazi/.config/yazi/keymap.toml";
      "yazi/yazi.toml".source = outOfStore "yazi/.config/yazi/yazi.toml";
    };

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
    tailscale-systray = {
      enable = true;
      theme = "dark:nobg";
    };
  };

  # Program configuration (The "Manager" Part)
  programs = {
    github-copilot-cli = {
      enable = true;

      package = pkgs.llm-agents.copilot-cli;
    };

    pi-coding-agent = {
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
          "npm:context-mode"
          "npm:pi-caveman"
          "npm:pi-rtk-optimizer"
          "npm:visual-explainer"
          "npm:pi-supergsd"
          "npm:@narumitw/pi-usage"
          # "npm:pi-cursor-sdk"
        ];
        retry = {
          enabled = true;
          maxRetries = 10;
        };
        theme = "dark";
      };
    };

    feh.enable = true;

    spotify-player.enable = lib.mkForce false;

    vesktop.enable = lib.mkForce false;

    yazi = {
      enable = true;

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

    neovim = {
      enable = true;
      # Existing init.lua is linked from config/vi below.
      sideloadInitLua = true;

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
    };

    # Zsh config is linked from config/zsh via home.file above.

    # VS Code: Managing extensions and settings
    vscode = {
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
  };

  # State Version (Do not change)
  home.stateVersion = "26.05";
}
