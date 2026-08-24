{ pkgs, ... }:
{
  users.users."steam" = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    packages = with pkgs; [ ];
  };
}
