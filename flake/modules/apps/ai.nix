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
    codex
    opencode
    copilot-cli

    # Tools
    t3code
    rtk

    # Interfaces
    chatgpt
    t3code-desktop
  ];
}
