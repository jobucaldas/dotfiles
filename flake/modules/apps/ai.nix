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
      };
    })
  ];

  environment.systemPackages = with pkgs.llm-agents; [
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
  ];
}
