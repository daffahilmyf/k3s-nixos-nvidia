{ lib, nodeInventory, ... }:

let
  cfg = nodeInventory.hardware.iommu or { };
  cpuVendor = nodeInventory.hardware.cpu.vendor or null;
  kernelParam =
    if cpuVendor == "intel" then
      "intel_iommu=on"
    else if cpuVendor == "amd" then
      "amd_iommu=on"
    else
      null;
in

{
  config = lib.mkIf (cfg.enable or false) {
    assertions = [
      {
        assertion = kernelParam != null;
        message = "hardware.iommu.enable requires hardware.cpu.vendor to be 'intel' or 'amd'.";
      }
    ];

    boot.kernelParams = [
      kernelParam
      "iommu=pt"
    ];
  };
}
