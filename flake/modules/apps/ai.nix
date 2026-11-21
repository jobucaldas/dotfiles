{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
lib.mkIf config.features.coding.enable {
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
    inputs.nixrepo.overlays.llm-agents-patches
    (final: prev: {
      # Background pi-subagents need the importable npm package and its peer
      # dependencies; the default Bun binary only carries a standalone layout.
      llm-agents = prev.llm-agents // {
        pi = prev.llm-agents.pi.override { useBun = false; };

        # openssl-sys fails to find OpenSSL when built against our nixpkgs
        # (not cached upstream either), so provide it explicitly.
        codex = prev.llm-agents.codex.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ final.openssl ];
          env = (old.env or { }) // {
            OPENSSL_NO_VENDOR = "1";
          };
        });
      };
    })
  ];

  environment.systemPackages =
    with pkgs.llm-agents;
    [
      # Harness
      pi
      grok
      codex
      opencode
      claude-code
      copilot-cli
      cursor-agent

      # Tools
      t3code
      rtk

      # Interfaces
      chatgpt
      grok-bot
      t3code-desktop
      claude-desktop
      # OpenBot 0.53.0's desktop entry no longer includes --no-sandbox.
      # Keep the upstream packaging until its substitution is corrected.
      (inputs.openbot.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        buildCommand =
          builtins.replaceStrings
            [ "Exec=AppRun --no-sandbox %U" ]
            [
              "Exec=AppRun %U"
            ]
            old.buildCommand;
      }))
      pkgs.code-cursor
    ]
    ++ [
      pkgs.openmausbot
    ]
    ++ [
      # Noctalia bar plugin `felipeartur/ai-usagebar` runs this by name.
      # Skip the upstream test suite; it rebuilds the crate with LTO.
      (inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        doCheck = false;
      })
    ];
}
