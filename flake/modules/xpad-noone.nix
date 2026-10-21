{ pkgs, lib, ... }:
{
  # Use Kbuild's installer so xpad-noone gets the deterministic signature and
  # .ko.cer required by nixpkgs' module aggregator. Remove when fixed upstream.
  boot.kernelPackages = lib.mkDefault (
    pkgs.linuxPackages.extend (
      final: prev: {
        xpad-noone = prev.xpad-noone.overrideAttrs (old: {
          installPhase = ''
            runHook preInstall

            make ${lib.escapeShellArgs old.makeFlags} \
              -C ${final.kernel.dev}/lib/modules/${final.kernel.modDirVersion}/build \
              M="$PWD" INSTALL_MOD_PATH="$out" \
              INSTALL_MOD_DIR=kernel/drivers/xpad-noone modules_install

            runHook postInstall
          '';
        });
      }
    )
  );
}
