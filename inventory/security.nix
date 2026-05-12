{
  sudo = {
    wheelNeedsPassword = true;
  };

  ssh = {
    allowUsers = [ "daffa" ];
    passwordAuthentication = false;
    permitRootLogin = "no";
    kbdInteractiveAuthentication = false;
    allowedTCPPorts = [ 22 ];
  };
}
