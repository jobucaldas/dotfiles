{ config, pkgs, lib, inputs, ... }:
{
  users.users."deploy" = {
    isNormalUser = true;
    shell = pkgs.bash;

    extraGroups = [ ];
    packages = with pkgs; [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMeizcZzKudDYpBMWPkLQwM4+u/7pdVrvlo21g0CLCz jobu@encom"
    ];
  };

  security.sudo.extraRules = [{
    users = [ "deploy" ];
    commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
    }];
  }];
}
