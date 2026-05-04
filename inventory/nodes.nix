{
  default = {
    role = "default";
  };

  control-plane = {
    staticIPv4 = "192.168.100.155";
    role = "control-plane";
  };

  cpu-worker-1 = {
    staticIPv4 = "192.168.100.156";
    role = "cpu-worker";
  };

  gpu-worker-1 = {
    staticIPv4 = "192.168.100.157";
    role = "gpu-worker";
    hardware = {
      cpu.vendor = "intel";
      gpu = {
        vendor = "nvidia";
        mode = "host-driver";
        vfio.pciIds = [ ];
      };
      iommu.enable = true;
      thermal.enable = true;
    };
    virtualization = {
      enable = true;
      bridge = {
        enable = true;
        name = "br0";
      };
    };
  };
}
