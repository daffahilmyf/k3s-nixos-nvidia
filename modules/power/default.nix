{
  infraInventory,
  lib,
  nodeInventory,
  ...
}:

let
  global = infraInventory.power or { };
  local = nodeInventory.power or { };
  cfg = global // local;
  gpu = nodeInventory.hardware.gpu or { };
  enableNvidia = (gpu.vendor or "") == "nvidia" && (gpu.mode or "host-driver") == "host-driver";
in

{
  config = lib.mkIf (cfg.enable or false) {
    powerManagement.cpuFreqGovernor = cfg.cpuGovernor or "schedutil";

    hardware.nvidia = lib.mkIf enableNvidia {
      nvidiaPersistenced = cfg.nvidia.persistenced or true;
      powerManagement.enable = cfg.nvidia.powerManagement or true;
    };
  };
}
