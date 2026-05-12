{
  lib,
  securityInventory,
  ...
}:

let
  cfg = securityInventory.ssh;
in

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = cfg.passwordAuthentication;
      PermitRootLogin = cfg.permitRootLogin;
      KbdInteractiveAuthentication = cfg.kbdInteractiveAuthentication;
    };
    extraConfig = lib.optionalString ((cfg.allowUsers or [ ]) != [ ]) ''
      AllowUsers ${lib.concatStringsSep " " cfg.allowUsers}
    '';
  };

  networking.firewall.allowedTCPPorts = cfg.allowedTCPPorts;
}
