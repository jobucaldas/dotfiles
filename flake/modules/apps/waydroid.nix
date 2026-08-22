{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Polaris needs DCC disabled for Gamescope DRM buffers.
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];

    user.services.gamescope-session.environment = {
      R600_DEBUG = "nodcc";
      RADV_DEBUG = "nodcc";
    };
  };

  # Waydroid-ATV video decoding needs DMA-BUF system heaps.
  boot.kernelPatches = [
    {
      name = "waydroid-dmabuf-heaps";
      patch = null;
      structuredExtraConfig = {
        DMABUF_HEAPS = lib.kernel.yes;
        DMABUF_HEAPS_SYSTEM = lib.kernel.yes;
      };
    }
  ];

  virtualisation = {
    waydroid = {
      enable = true;

      # Newer kernel versions may need
      package = pkgs.waydroid-nftables;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      pkgs.waydroid-helper
      pkgs.wl-clipboard

      (writeShellApplication {
        name = "waydroid-gamescope";
        runtimeInputs = [
          cage
          wlr-randr
        ];
        text = ''
          if [ -z "''${DISPLAY:-}" ]; then
            echo "No Gamescope XWayland display found" >&2
            exit 1
          fi

          export WLR_BACKENDS=x11
          unset WAYLAND_DISPLAY

          exec cage -s -- ${pkgs.bash}/bin/bash -c '
            wlr-randr --output X11-1 --custom-mode 1920x1080
            exec ${config.virtualisation.waydroid.package}/bin/waydroid "$@"
          ' waydroid-cage "$@"
        '';
      })
    ];
  };
}