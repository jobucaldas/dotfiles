{ pkgs, ... }:

let
  # Set Steam's "Sleep after" timers to Disabled (0) in config.vdf.
  disableIdleSuspend = pkgs.writers.writePython3 "steam-disable-idle-suspend" { } ''
    import os
    import re
    import sys

    path = sys.argv[1]
    keys = ("IdleSuspendACSeconds", "IdleSuspendBatterySeconds")

    if not os.path.exists(path):
        sys.exit(0)

    with open(path) as f:
        text = f.read()

    system = re.search(r'\n(\t+)"System"\n\t+\{\n', text)
    if system is None:
        print(f"no System block in {path}, leaving it unchanged")
        sys.exit(0)

    indent = system.group(1) + "\t"
    start = system.end()
    end = text.index("\n" + system.group(1) + "}", start)
    block = text[start:end]
    for key in keys:
        block = re.sub(rf'\t+"{key}"\t+"[^"]*"\n?', "", block)
        block = block.rstrip("\n") + f'\n{indent}"{key}"\t\t"0"'
    new = text[:start] + block.lstrip("\n") + text[end:]

    if new != text:
        tmp = path + ".tmp"
        with open(tmp, "w") as f:
            f.write(new)
        os.replace(tmp, path)
  '';
in
{
  # Suspend is disabled on this host, but Steam's idle timer still asks logind
  # to suspend. logind refuses with SleepVerbNotSupported and Steam never gets a
  # resume, so its main view stays frozen until Steam restarts. Steam only reads
  # config.vdf at startup and rewrites it on exit, so set it before each start.
  systemd.user.services.steam-disable-idle-suspend = {
    description = "Disable Steam's idle suspend timer";
    wantedBy = [ "steam-launcher.service" ];
    before = [ "steam-launcher.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${disableIdleSuspend} %h/.local/share/Steam/config/config.vdf";
    };
  };
}
