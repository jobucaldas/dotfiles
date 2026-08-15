{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  # Feature flag to enable mangowm
  options.features.desktop = lib.mkOption {
    type = lib.types.enum [
      "mango"
      "niri"
      "gnome"
    ];
    default = "mango";

    description = "Desktop environment/window manager";
  };

  config = lib.mkMerge [
    (lib.mkIf (config.features.desktop == "mango") {
      imports = [
        ./mango.nix
      ];
    })

    (lib.mkIf (config.features.desktop == "niri") {
      imports = [
        ./niri.nix
      ];
    })

    (lib.mkIf (config.features.desktop == "gnome") {
      imports = [
        ./gnome.nix
      ];
    })
  ];
}