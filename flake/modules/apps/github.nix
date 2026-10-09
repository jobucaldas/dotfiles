{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.features.coding.enable {
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "gh";
      runtimeInputs = with pkgs; [
        bws
        jq
        coreutils
      ];
      text = ''
        if [[ -z "''${GH_TOKEN:-}" && -z "''${GITHUB_TOKEN:-}" ]]; then
          token_file="''${HOME}/.config/bws/laptop.token"
          if [[ -r "$token_file" ]]; then
            if token="$(
              export BWS_ACCESS_TOKEN
              BWS_ACCESS_TOKEN="$(< "$token_file")"
              timeout 15s bws secret get 4974df51-6d54-48a4-96d3-b4da0164548b --output json |
                jq -er '.value | select(type == "string" and length > 0 and (test("[\\r\\n]") | not))'
            )"; then
              export GH_TOKEN="$token"
              unset token
            else
              printf '%s\n' 'gh: BWS unavailable; trying existing gh authentication.' >&2
            fi
          fi
        fi
        # Do not pass the BWS credential to gh
        unset BWS_ACCESS_TOKEN
        exec ${pkgs.gh}/bin/gh "$@"
      '';
    })
  ];
}
