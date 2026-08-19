{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  # Enable the GNOME Desktop Environment.
  # Jovian autoStart enables SDDM; GDM conflicts with it.
  services.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = true;
  services.desktopManager.gnome.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}