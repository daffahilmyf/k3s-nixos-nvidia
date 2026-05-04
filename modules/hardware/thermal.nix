{
  lib,
  nodeInventory,
  pkgs,
  ...
}:

let
  cfg = nodeInventory.hardware.thermal or { };
in

{
  config = lib.mkIf (cfg.enable or false) {
    services.thermald.enable = true;
    services.smartd.enable = true;

    environment.systemPackages = with pkgs; [
      lm_sensors
      nvme-cli
      smartmontools
    ];
  };
}
