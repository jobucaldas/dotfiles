outputs = { self, nixpkgs }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  
in {
  services.flatpak = {
    enable = true;

    packages = [
    "it.mijorus.gearlever"
    ];
  };

  packages.x86_64-linux.default =
    pkgs.runCommand "install-package" { } ''
      gearlever --install 
    '';
};