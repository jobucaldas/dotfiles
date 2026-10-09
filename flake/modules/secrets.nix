{
  config,
  inputs,
  lib,
  ...
}:

let
  passwordSecret = "jobu-password-hash-${config.networking.hostName}";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/dotfiles.enc.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      ${passwordSecret} = {
        neededForUsers = true;
        mode = "0400";
      };

      "tailscale-authkey" = {
        mode = "0400";
      };
    };
  };

  users.users.jobu.hashedPasswordFile = config.sops.secrets.${passwordSecret}.path;

  services.tailscale.authKeyFile = config.sops.secrets."tailscale-authkey".path;
  systemd.services.tailscaled-autoconnect = lib.mkIf config.sops.useSystemdActivation {
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
  };
}
