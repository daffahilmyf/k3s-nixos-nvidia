{ securityInventory, ... }:

{
  security = {
    sudo.wheelNeedsPassword = securityInventory.sudo.wheelNeedsPassword;
    rtkit.enable = false;
  };
}
