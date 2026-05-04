{ systemSettings, ... }:

{
  boot.loader.systemd-boot.configurationLimit = systemSettings.bootConfigurationLimit;

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=14day
  '';
}
