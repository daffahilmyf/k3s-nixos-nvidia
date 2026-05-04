{ lib, nodeInventory, ... }:

let
  gpu = nodeInventory.hardware.gpu or { };
  vfio = gpu.vfio or { };
  pciIds = vfio.pciIds or [ ];
  enabled = (gpu.mode or "host-driver") == "vfio-passthrough";
in

{
  config = lib.mkIf enabled {
    assertions = [
      {
        assertion = pciIds != [ ];
        message = "GPU VFIO passthrough requires hardware.gpu.vfio.pciIds in inventory.";
      }
    ];

    boot = {
      initrd.kernelModules = [
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "vfio_virqfd"
      ];

      kernelParams = [
        "vfio-pci.ids=${lib.concatStringsSep "," pciIds}"
      ];

      blacklistedKernelModules = lib.optionals ((gpu.vendor or null) == "nvidia") [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];
    };
  };
}
