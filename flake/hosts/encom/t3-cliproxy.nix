{
  config,
  pkgs,
  lib,
  ...
}:
let
  home = config.users.users.jobu.home;
  baseUrl = "http://cliproxyapi.tailbe71e1.ts.net:8317";
  # Bitwarden `cluster` project; the `cluster` machine account reads it.
  clusterProject = "cfd59b69-ae74-4692-b06c-b49101022445";
  tokenFile = "${home}/.config/bws/cluster.token";
  # Local gateway that adds usage-limit reset times to cliproxyapi's errors;
  # T3's Claude talks to it instead of the proxy.
  gatewayPort = 18317;
  gatewayUrl = "http://127.0.0.1:${toString gatewayPort}";

  # Points T3's Claude provider at cliproxyapi and offers every chat model the
  # proxy serves. The key lands in the instance environment of T3's
  # settings.json (mode 0600), which T3 passes to Claude.
  sync = pkgs.writeShellScript "t3-cliproxy-sync" ''
    set -euo pipefail
    export PATH=${
      lib.makeBinPath [
        pkgs.bws
        pkgs.curl
        pkgs.jq
        pkgs.coreutils
      ]
    }
    key="$(BWS_ACCESS_TOKEN="$(< ${lib.escapeShellArg tokenFile})" bws secret list ${clusterProject} \
      | jq -r '.[] | select(.key == "CLIPROXYAPI_API_KEY") | .value')"
    test -n "$key"
    models="$(curl -fsS -m 15 -H "Authorization: Bearer $key" ${baseUrl}/v1/models \
      | jq -c '[.data[].id | select(test("image|video|tts|embed|imagine") | not)] | sort | map({slug: ., name: .})')"
    test "$models" != "[]"
    for settings in "$@"; do
      mkdir -p "$(dirname "$settings")"
      [ -f "$settings" ] || echo '{}' > "$settings"
      umask 0077
      jq --argjson m "$models" --arg key "$key" --arg url ${lib.escapeShellArg gatewayUrl} '
        .providerInstances.claudeAgent |= (
          (. // {driver: "claudeAgent"})
          | .config = ((.config // {}) | .customModels = $m)
          | .environment = (
              ((.environment // []) | map(select(.name != "ANTHROPIC_BASE_URL" and .name != "ANTHROPIC_AUTH_TOKEN")))
              + [
                  {name: "ANTHROPIC_BASE_URL", value: $url, sensitive: false},
                  {name: "ANTHROPIC_AUTH_TOKEN", value: $key, sensitive: true}
                ]))' \
        "$settings" > "$settings.new"
      chmod 600 "$settings.new"
      mv "$settings.new" "$settings"
    done
  '';
  serverSettings = "${home}/.local/share/t3code-server/userdata/settings.json";
  localSettings = "${home}/.t3/userdata/settings.json";
in
{
  home-manager.users.jobu.systemd.user = {
    services.t3-cliproxy-gateway = {
      Unit.Description = "Adds usage-limit reset times to cliproxyapi errors for T3 Code";
      Service = {
        Environment = [
          "UPSTREAM=${baseUrl}"
          "PORT=${toString gatewayPort}"
        ];
        ExecStart = "${lib.getExe pkgs.nodejs} ${./t3-cliproxy-gateway.js}";
        Restart = "always";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };

    # Best effort before the server starts: a proxy outage must not keep it down.
    services.t3-serve.Service.ExecStartPre = [ "-${sync} ${serverSettings}" ];

    # The desktop app's own (local) instance.
    services.t3-cliproxy-sync-local = {
      Unit.Description = "Point the local T3 Code at cliproxyapi";
      Service = {
        Type = "oneshot";
        ExecStart = "${sync} ${localSettings}";
      };
      Install.WantedBy = [ "default.target" ];
    };
    timers.t3-cliproxy-sync-local = {
      Unit.Description = "Refresh cliproxyapi models for the local T3 Code";
      Timer = {
        OnStartupSec = "2min";
        OnUnitActiveSec = "6h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
