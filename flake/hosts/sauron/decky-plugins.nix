{ pkgs, ... }:

{
  nixrepo.decky-loader.plugins = {
    "SDH-AnimationChanger" = pkgs.deckyPlugins."SDH-AnimationChanger";
    "SDH-AudioLoader" = pkgs.deckyPlugins."SDH-AudioLoader";
    "deck-progress-tracker" = pkgs.deckyPlugins."deck-progress-tracker";
    "decky-download-all" = pkgs.deckyPlugins."decky-download-all";
    "MangoPeel" = pkgs.deckyPlugins."MangoPeel";
    "decky-nonsteam-badges" = pkgs.deckyPlugins."decky-nonsteam-badges";
    "playcount-decky" = pkgs.deckyPlugins."playcount-decky";
    "SDH-PlayTime" = pkgs.deckyPlugins."SDH-PlayTime";
    "protondb-decky" = pkgs.deckyPlugins."protondb-decky";
    "decky-steamgriddb" = pkgs.deckyPlugins."decky-steamgriddb";
    "VolumeMixer-decky" = pkgs.deckyPlugins."VolumeMixer-decky";
    "SDH-CssLoader" = pkgs.deckyPlugins."SDH-CssLoader";
    "SDH-GameThemeMusic" = pkgs.deckyPlugins."SDH-GameThemeMusic";
    "Junk-Store" = pkgs.deckyPlugins."Junk-Store";
    "TabMaster" = pkgs.deckyPlugins."TabMaster";
    "decky-terminal" = pkgs.deckyPlugins."decky-terminal";
    "hltb-for-deck" = pkgs.deckyPlugins."hltb-for-deck-2_0_10";
  };
}
