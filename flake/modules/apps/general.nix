{ pkgs, ... }:
{
  # The browser is defined once; every web app contributed by another module
  # uses this package unless this option is overridden by a host.
  webApps = {
    browser = pkgs.helium;

    entries.whatsapp = {
      name = "WhatsApp";
      url = "https://web.whatsapp.com";
      comment = "WhatsApp web client";
      keywords = [ "Chat" ];
    };
  };

  environment.systemPackages = with pkgs; [
    crunchyroll-linux
    vacuumtube
    helium
    anki
    kodi
    filezilla
    spotify
    vesktop
  ];
}
