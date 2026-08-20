{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.jovian-nixos.nixosModules.default
  ];

  # Feature flag to enable gamescope session
  options.features.gamescopeSession.enable = lib.mkEnableOption "gamescope-session";

  config = lib.mkMerge [
    (lib.mkIf config.features.gamescopeSession.enable {
      jovian = {
        steam = {
          autoStart = true;
          desktopSession = config.features.defaultDesktop;
          user = "jobu";
        };
      };
    })

    {
      virtualisation = {
        waydroid = {
          enable = true;

          # Newer kernel versions may need
          package = pkgs.waydroid-nftables;
        };
      };

      # Setup applications
      programs = {
        # Workaround to run apps that look for libraries directly (example: Dotnet Mod Loaders)
        # nix-ld = {
        #   enable = true;
        #   libraries = with pkgs; [
        #     icu
        #     libice
        #     libsm
        #     libx11
        #
        #     fontconfig
        #     freetype
        #
        #     libxcursor
        #     libxext
        #     libxfixes
        #     libxi
        #     libxrandr
        #     libxrender
        #     libxtst
        #     libxkbcommon
        #   ];
        # };

        # Install steam
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;

          gamescopeSession.enable = true;

          protontricks.enable = true;
        };

        # Optimize system performance for gaming on demand
        gamemode.enable = true;
        gamescope.enable = true;
      };

      jovian = {
        steam = {
          enable = true;
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

      systemd = {
        services.decky-loader.path = with pkgs; [
          systemd
          python3
        ];
      };

      environment = {
        sessionVariables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        };

        systemPackages = with pkgs; [
          ## Apps
          protonplus
          (heroic.override {
            extraPkgs =
              pkgs': with pkgs'; [
                gamescope
                gamemode
              ];
          })

          pkgs.wl-clipboard 
        ];
      };
    }
  ];

}