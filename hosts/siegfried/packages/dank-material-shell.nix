{
  inputs,
  quickshell,
  ...
}: {
  imports = [inputs.dms.homeModules.dank-material-shell];

  programs.dank-material-shell = {
    enable = true;
    quickshell.package = quickshell;

    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    enableVPN = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
}
