{ pkgs, ... }:

let
  # Names and Bitwarden item references only, never secret values.
  manifest = ../../../secretspec.toml;
in
{
  environment.systemPackages = with pkgs; [
    bws
    secretspec
  ];

  # SDDM autologin never supplies a password, so the login keyring stays locked
  # and every app that needs it stalls. Start the Secret Service unlocked with
  # the password from SecretSpec instead. --login reads the password from stdin,
  # the same way PAM starts the daemon after a password login.
  systemd.user.services.keyring-unlock = {
    description = "Start the login keyring unlocked with the SecretSpec password";
    wantedBy = [ "default.target" ];
    # User units start for every user; only jobu has the token and the keyring.
    unitConfig.ConditionUser = "jobu";
    path = [ pkgs.bws ];

    script = ''
      set -o pipefail
      # Session D-Bus activation can start a locked daemon before this unit runs.
      # --login then exits, so stop any other daemon first.
      ${pkgs.procps}/bin/pkill -f 'gnome-keyring-daemon --' || true
      sleep 2
      export BWS_ACCESS_TOKEN="$(< "$HOME/.config/bws/laptop.token")"
      export SECRETSPEC_REASON="sauron login keyring unlock"
      ${pkgs.secretspec}/bin/secretspec -f ${manifest} get SAURON_KEYRING_PASSWORD --profile default \
        | ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --login --foreground --components=secrets -C "$XDG_RUNTIME_DIR/keyring"
    '';

    serviceConfig = {
      Type = "simple";
      # A fixed control directory lets gnome-keyring-daemon --unlock find this daemon.
      RuntimeDirectory = "keyring";
      RuntimeDirectoryMode = "0700";
      # The daemon can also exit cleanly, which would leave the keyring locked.
      Restart = "always";
      RestartSec = 30;
    };
  };
}
