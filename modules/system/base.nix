{ pkgs, ... }:

{
  system.stateVersion = "25.11";

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = false;
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  time.timeZone = "Asia/Jakarta";
}
