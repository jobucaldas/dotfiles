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
  services.desktopManager.gnome.enable = true;

  
}