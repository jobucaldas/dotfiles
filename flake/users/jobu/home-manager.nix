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

      # Noctalia stores its config in XDG_STATE_HOME (settings.toml only;
      # runtime data like clipboard/notification history stays unmanaged).
      ".local/state/noctalia/settings.toml".source =
        outOfStore "noctalia/.local/state/noctalia/settings.toml";
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
            url = "https://pub-74b82010d1dc4231af9954113cda4e1c.r2.dev/cursors/Remus-White.zip";
            hash = "sha256-hq4adOjB0ViCpzmhm9tn74RX4VbgZVp+YFHz8apIgC8=";
            extension = "zip";
          }
        }/Remus-White "$out/share/icons/Remus-White"
      '';
    };
  };

  xdg = {
    # Keep config editable in repository. Home Manager creates links only
    configFile = {
      "DankMaterialShell/.changelog-1.5".source =
        outOfStore "dms/.config/DankMaterialShell/.changelog-1.5";
      "DankMaterialShell/.firstlaunch".source = outOfStore "dms/.config/DankMaterialShell/.firstlaunch";
      "DankMaterialShell/monitors.json".source = outOfStore "dms/.config/DankMaterialShell/monitors.json";
      "DankMaterialShell/plugin_settings.json".source =
        outOfStore "dms/.config/DankMaterialShell/plugin_settings.json";
      "DankMaterialShell/settings.json".source = outOfStore "dms/.config/DankMaterialShell/settings.json";

      "git/config".source = outOfStore "git/.config/git/config";

      "kitty/kitty.conf".source = outOfStore "kitty/.config/kitty/kitty.conf";
      "kitty/tabs.conf".source = outOfStore "kitty/.config/kitty/tabs.conf";
      "kitty/theme.conf".source = outOfStore "kitty/.config/kitty/theme.conf";

      "mango/binds.conf".source = outOfStore "mango/.config/mango/binds.conf";
      "mango/colors.conf".source = outOfStore "mango/.config/mango/colors.conf";
      "mango/config.conf".source = outOfStore "mango/.config/mango/config.conf";
      "mango/cursor.conf".source = outOfStore "mango/.config/mango/cursor.conf";
      "mango/layout.conf".source = outOfStore "mango/.config/mango/layout.conf";
      "mango/outputs.conf".source = outOfStore "mango/.config/mango/outputs.conf";
      "mango/windowrules.conf".source = outOfStore "mango/.config/mango/windowrules.conf";

      "mpv/mpv.conf".source = outOfStore "mpv/.config/mpv/mpv.conf";

      "niri/config.kdl".source = outOfStore "niri/.config/niri/config.kdl";
      "niri/dms/alttab.kdl".source = outOfStore "niri/.config/niri/dms/alttab.kdl";
      "niri/dms/binds.kdl".source = outOfStore "niri/.config/niri/dms/binds.kdl";
      "niri/dms/colors.kdl".source = outOfStore "niri/.config/niri/dms/colors.kdl";
      "niri/dms/cursor.kdl".source = outOfStore "niri/.config/niri/dms/cursor.kdl";
      "niri/dms/layout.kdl".source = outOfStore "niri/.config/niri/dms/layout.kdl";
      "niri/dms/outputs.kdl".source = outOfStore "niri/.config/niri/dms/outputs.kdl";
      "niri/dms/windowrules.kdl".source = outOfStore "niri/.config/niri/dms/windowrules.kdl";
      "niri/dms/wpblur.kdl".source = outOfStore "niri/.config/niri/dms/wpblur.kdl";

      "nvim/colors/dms.lua".source = outOfStore "vi/.config/nvim/colors/dms.lua";
      "nvim/init.lua".source = outOfStore "vi/.config/nvim/init.lua";
      "nvim/lazy-lock.json".source = outOfStore "vi/.config/nvim/lazy-lock.json";
      "nvim/lazyvim.json".source = outOfStore "vi/.config/nvim/lazyvim.json";
      "nvim/lua/lualine/themes/dms.lua".source = outOfStore "vi/.config/nvim/lua/lualine/themes/dms.lua";

      "spotifyd/spotifyd.conf".source = outOfStore "spotifyd/.config/spotifyd/spotifyd.conf";

      "spotify-player/app.toml".source = outOfStore "spotify-player/.config/spotify-player/app.toml";

      "tmux/tmux.conf".source = outOfStore "tmux/.config/tmux/tmux.conf";

      "opencode/opencode.json".source = outOfStore "opencode/.config/opencode/opencode.json";

      # Link only intentional Vesktop config. Runtime data stays in ~/.config/vesktop.
      "vesktop/settings.json".source = outOfStore "vesktop/.config/vesktop/settings.json";
      "vesktop/settings/settings.json".source =
        outOfStore "vesktop/.config/vesktop/settings/settings.json";
      "vesktop/settings/quickCss.css".source = outOfStore "vesktop/.config/vesktop/settings/quickCss.css";

      "yazi/keymap.toml".source = outOfStore "yazi/.config/yazi/keymap.toml";
      "yazi/yazi.toml".source = outOfStore "yazi/.config/yazi/yazi.toml";

      # Dictation (xhisper reads ~/.config/xhisper/xhisperrc).
      "xhisper/xhisperrc".source = outOfStore "xhisper/.config/xhisper/xhisperrc";
    };

    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "helium.desktop";
        "application/xhtml+xml" = "helium.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";

        "image/png" = "swayimg.desktop";
        "image/jpeg" = "swayimg.desktop";
        "image/gif" = "swayimg.desktop";
        "image/webp" = "swayimg.desktop";
        "image/bmp" = "swayimg.desktop";
        "image/tiff" = "swayimg.desktop";
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
    neovim = {
      enable = true;

      # Existing init.lua is linked from config/vi
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
  };

  # State Version (Do not change)
  home.stateVersion = "26.05";
}
