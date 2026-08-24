{ config, pkgs, inputs, lib, ... }:
lib.mkIf config.features.coding.enable {
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
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
