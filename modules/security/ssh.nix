{ securityInventory, ... }:

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
  };

  networking.firewall.allowedTCPPorts = cfg.allowedTCPPorts;
}
