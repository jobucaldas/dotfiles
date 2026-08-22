{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  steamInputKeylayout = pkgs.writeText "Vendor_28de_Product_11ff.kl" ''
    # Steam Input virtual Xbox controller (28de:11ff)
    key 304   BUTTON_A
    key 305   BUTTON_B
    key 307   BUTTON_X
    key 308   BUTTON_Y
    key 310   BUTTON_L1
    key 311   BUTTON_R1
    axis 0x02 LTRIGGER
    axis 0x05 RTRIGGER
    axis 0x00 X
    axis 0x01 Y
    axis 0x03 Z
    axis 0x04 RZ
    key 317   BUTTON_THUMBL
    key 318   BUTTON_THUMBR
    axis 0x10 HAT_X
    axis 0x11 HAT_Y
    key 314   BUTTON_SELECT
    key 315   BUTTON_START
    key 316   BUTTON_MODE
  '';
in
{
  # Polaris needs DCC disabled for Gamescope DRM buffers.
  systemd = {
    packages = [ pkgs.waydroid-helper ];

    services = {
      waydroid-mount.wantedBy = [ "multi-user.target" ];

      # Android must listen for host uevents before InputPlumber's virtual
      # controller can be discovered. Also translate mouse clicks to touch for
      # Epic apps, which otherwise ignore pointer button events.
      waydroid-input-setup = {
        description = "Configure Waydroid input integration";
        wantedBy = [ "multi-user.target" ];
        before = [ "waydroid-container.service" ];
        path = with pkgs; [
          coreutils
          gnugrep
          gnused
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          install -d /var/lib/waydroid/overlay/system/usr/keylayout
          install -m 0644 ${steamInputKeylayout} \
            /var/lib/waydroid/overlay/system/usr/keylayout/Vendor_28de_Product_11ff.kl

          touch /var/lib/waydroid/waydroid_base.prop
          sed -i \
            -e '/^persist\.waydroid\.udev=/d' \
            -e '/^persist\.waydroid\.uevent=/d' \
            -e '/^persist\.waydroid\.fake_touch=/d' \
            /var/lib/waydroid/waydroid_base.prop
          cat >> /var/lib/waydroid/waydroid_base.prop <<'EOF'
          persist.waydroid.udev=true
          persist.waydroid.uevent=true
          persist.waydroid.fake_touch=com.epicgames.*
          EOF
        '';
      };

      # Android's uevent bridge starts after surfaceflinger. Re-announce each
      # InputPlumber virtual input node whenever a new Android session starts.
      waydroid-controller-monitor = {
        description = "Rescan controllers for Waydroid sessions";
        wantedBy = [ "multi-user.target" ];
        after = [
          "inputplumber.service"
          "waydroid-container.service"
        ];
        path = with pkgs; [
          coreutils
          procps
        ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 2;
        };
        script = ''
          last_pid=""
          while sleep 1; do
            pid="$(pgrep -x surfaceflinger | head -n 1 || true)"
            if [ -n "$pid" ] && [ "$pid" != "$last_pid" ]; then
              sleep 10
              for event in /sys/devices/virtual/input/input*/event*/uevent; do
                if [ -e "$event" ]; then
                  echo add > "$event" || true
                fi
              done
              last_pid="$pid"
            elif [ -z "$pid" ]; then
              last_pid=""
            fi
          done
        '';
      };
    };

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
      android-tools
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
