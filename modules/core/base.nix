{ systemSettings, ... }:

{
  system.stateVersion = systemSettings.stateVersion;

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = false;
  };

  environment.variables = {
    EDITOR = systemSettings.editor;
    VISUAL = systemSettings.editor;
  };

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  time.timeZone = systemSettings.timeZone;
}
