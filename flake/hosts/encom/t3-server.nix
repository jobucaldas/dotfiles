{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  home = config.users.users.jobu.home;
  server = pkgs.callPackage ../../packages/t3-server.nix {
    src = inputs.t3code-release;
    providerPackages = pkgs.llm-agents.t3code.providerPackages;
  };
in
{
  users.users.jobu.linger = true;

  home-manager.users.jobu = {
    home.file.".local/bin/t3-encom".source = lib.getExe server;

    systemd.user.services.t3-serve = {
      Unit = {
        Description = "Persistent T3 Code server on Encom's tailnet";
        StartLimitIntervalSec = 0;
      };
      Service = {
        UMask = "0077";
        WorkingDirectory = "${home}/Projects";
        Environment = [
          "HOME=${home}"
          "SHELL=${lib.getExe pkgs.bash}"
        ];
        ExecStartPre = "${lib.getExe config.services.tailscale.package} status";
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe server)
          "serve --mode web --host 127.0.0.1 --port 14312"
          "--base-dir ${home}/.local/share/t3code-server"
          "--no-browser --auto-bootstrap-project-from-cwd"
          "--tailscale-serve --tailscale-serve-port 9443"
          "${home}/Projects"
        ];
        Restart = "always";
        RestartSec = 30;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
