{
  lib,
  stdenv,
  patchelf,
  makeWrapper,
  src,
  providerPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "t3code-server";
  version = "0.1.6";
  inherit src;

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];
  dontBuild = true;
  dontStrip = true;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/t3code" "$out/bin"
    cp -a . "$out/libexec/t3code/"
    chmod u+w "$out/libexec/t3code/t3"
    patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
      --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]} "$out/libexec/t3code/t3"
    makeWrapper "$out/libexec/t3code/t3" "$out/bin/t3" \
      --prefix PATH : ${lib.makeBinPath providerPackages}
    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/t3" --version | grep -Fx "t3 v${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "T3 Code headless server from the official release";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "t3";
  };
})
