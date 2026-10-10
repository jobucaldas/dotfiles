{ pkgs, ... }:

{
  nixrepo.decky-loader.plugins = {
    "SDH-AnimationChanger" = pkgs.deckyPlugins."SDH-AnimationChanger";
    "SDH-AudioLoader" = pkgs.deckyPlugins."SDH-AudioLoader";
    "SDH-CssLoader" = pkgs.deckyPlugins."SDH-CssLoader";
    "SDH-GameThemeMusic" = pkgs.deckyPlugins."SDH-GameThemeMusic";
    "hltb-for-deck" = pkgs.deckyPlugins."hltb-for-deck-2_0_9";
    "playcount-decky" = pkgs.deckyPlugins."playcount-decky";
    "protondb-decky" = pkgs.deckyPlugins."protondb-decky";
    "decky-steamgriddb" = pkgs.deckyPlugins."decky-steamgriddb";
    "TabMaster" = pkgs.deckyPlugins."TabMaster";
    "Junk-Store" = pkgs.deckyPlugins."Junk-Store";
  };
}
