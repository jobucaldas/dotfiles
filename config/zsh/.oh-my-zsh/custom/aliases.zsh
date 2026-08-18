alias -- ll='ls -l'
alias -- nix-clean='nix store gc'
alias -- nix-rebuild='nix flake update --flake ${HOME}/Projects/dotfiles/flake'
alias -- nix-rollback='sudo nixos-rebuild switch --rollback'
alias -- nix-test='sudo nixos-rebuild test --flake ${HOME}/Projects/dotfiles/flake#$(hostname)'
alias -- nix-update='sudo nixos-rebuild switch --flake ${HOME}/Projects/dotfiles/flake#$(hostname)'
alias -- spcli=spotify_player
alias -- gearlever='flatpak run it.mijorus.gearlever'
