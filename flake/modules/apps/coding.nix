{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
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
    
    ## Languages
    python3
    nodejs
  ];
}