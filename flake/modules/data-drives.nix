{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dataDrives;
in
{
  options.dataDrives = {
    owner = lib.mkOption {
      type = lib.types.str;
      default = "jobu";
      description = "User that owns the contents of the data drives.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group that owns the contents of the data drives.";
    };

    mountpoints = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Mounted data drives whose contents should belong to the owner. Disko
        only describes the layout, so ownership of existing files is applied
        on every boot and switch. Root-owned files are left alone.
      '';
    };
  };

  config = lib.mkIf (cfg.mountpoints != [ ]) {
    systemd.services.data-drives-ownership = {
      description = "Give ${cfg.owner} ownership of the data drives";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      unitConfig.ConditionPathIsMountPoint = cfg.mountpoints;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "data-drives-ownership" ''
          set -euo pipefail
          for drive in ${lib.escapeShellArgs cfg.mountpoints}; do
            ${pkgs.findutils}/bin/find "$drive" -xdev ! -user root ! -user ${cfg.owner} -exec ${pkgs.coreutils}/bin/chown -h ${cfg.owner}:${cfg.group} {} +
          done
        '';
      };
    };
  };
}
