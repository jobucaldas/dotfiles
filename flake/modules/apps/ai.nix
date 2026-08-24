{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
  ];

  environment.systemPackages = with pkgs.llm-agents; [
    pi-coding-agent
    rtk
    opencode
    copilot-cli
    t3code-desktop
  ];
}
