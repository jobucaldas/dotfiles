{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./ai.nix
  ];

  config = lib.mkIf config.features.coding.enable {
    virtualisation.podman = {
      enable = true;

      # Create a "docker" alias so you can still type "docker run ..."
      dockerCompat = true;

      # DNS name resolution for containers
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      ## CLI
      bws
      awscli
      kubectl
      ansible
      opentofu
      podman-compose

      ## Apps
      vscode

      ## Languages
      gcc
      bun
      cargo
      rustup
      nodejs
      python3

      # Nix
      nil
      nixfmt
      statix
    ];
  };
}
