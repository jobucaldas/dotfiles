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
    git
    bws
    awscli
    kubectl
    python3
    ansible
    opentofu
    podman-compose
  ];

  # Setup applications
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    zsh.enable = true;

    tmux = {
      enable = true;

      keyMode = "vi";

      plugins = with pkgs.tmuxPlugins; [
        cpu
        resurrect
        continuum
        yank
        battery
        better-mouse-mode
        tokyo-night-tmux
      ];

      extraConfig = "
        set -g mouse on
        set -g xterm-keys on
        set -s extended-keys on
        set -s extended-keys-format csi-u
        set -as terminal-features ',xterm*:extkeys,tmux*:extkeys,screen*:extkeys'
        set -sg escape-time 10
      ";
    };
  };
}