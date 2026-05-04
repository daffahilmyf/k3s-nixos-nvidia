{
  sudo = {
    wheelNeedsPassword = false;
  };

  ssh = {
    passwordAuthentication = false;
    permitRootLogin = "no";
    kbdInteractiveAuthentication = false;
    allowedTCPPorts = [ 22 ];
  };
}
