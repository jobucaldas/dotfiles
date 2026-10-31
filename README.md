# Dotfiles

Personal dotfiles for my machines, more so a backup for me and a base for people who want to do the same.

## Instalation

Clone repository and copy/move the files to your home directory.

```bash
git clone -b nix https://github.com/jobucaldas/dotfiles.git
cd dotfiles
sudo nixos-rebuild switch --flake ~/Projects/dotfiles/flake#encom
```

## AI usage bar

Coding-enabled hosts install `ai-usagebar` for the
`felipeartur/ai-usagebar` Noctalia plugin. The bar replaces Claude Cockpit and
uses the `bar_2` widget. The package keeps upstream's own nixpkgs pin and its
test suite enabled.

## Encom T3 server

Encom runs a persistent `t3-serve` user service, independently of the desktop
app. User lingering starts it at boot without a graphical login; crashes are
restarted, and startup retries while Tailscale is unavailable. Suspend still
pauses the laptop and its services.

The backend binds only to `127.0.0.1:14312`. Tailscale Serve publishes
`https://encom.tailbe71e1.ts.net:9443`; port `8443` remains the existing
development route. Add `https://encom.tailbe71e1.ts.net:9443/mcp` as a
Streamable HTTP server in OpenMausBot, test it, and choose **Sign in**.

State lives in `~/.local/share/t3code-server`, separate from the desktop's
`~/.t3`; projects are under `~/Projects`. Existing provider credentials in
your home directory remain available to the service. Create a pairing code
for its approval page with:

```sh
t3-encom auth pairing create --base-dir ~/.local/share/t3code-server \
  --ttl 5m --label MausBot --base-url https://encom.tailbe71e1.ts.net:9443
```

Use `systemctl --user status t3-serve` or
`journalctl --user -u t3-serve` to inspect it. The headless release is pinned
separately in `flake/flake.nix` and `flake/flake.lock`; update the release URL
and `flake/packages/t3-server.nix` version together, then run
`nix flake update t3code-release` from `flake/`.
