{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./wm.nix
  ];

  nixpkgs = {
    # Fix for xwayland-satellite
    overlays = [
      (final: prev: {
        steam = prev.steam.override {
          extraArgs = "-system-composer";
        };
      })
    ];
  };

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
  };
}