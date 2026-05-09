{
  infraInventory,
  lib,
  nodeInventory,
  systemSettings,
  ...
}:

let
  global = infraInventory.recovery or { };
  local = nodeInventory.recovery or { };
  serial = (global.serialConsole or { }) // (local.serialConsole or { });
  rescueSsh = (global.rescueSsh or { }) // (local.rescueSsh or { });
  rescueUser = rescueSsh.user or "rescue";
in

{
  boot.loader.systemd-boot.configurationLimit = systemSettings.bootConfigurationLimit;
  boot.kernelParams = lib.mkIf (serial.enable or false) [
    "console=tty0"
    "console=ttyS0,115200n8"
  ];

  users.users.${rescueUser} = lib.mkIf (rescueSsh.enable or false) {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = rescueSsh.authorizedKeys or [ ];
  };

  services.openssh.extraConfig = lib.mkIf (rescueSsh.enable or false) ''
    Match User ${rescueUser}
      PasswordAuthentication no
      KbdInteractiveAuthentication no
  '';

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=14day
  '';
}
