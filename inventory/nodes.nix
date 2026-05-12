{
  default = {
    role = "default";
  };

  control-plane = {
    staticIPv4 = "192.168.100.160";
    role = "control-plane";
    hardware = {
      cpu.vendor = "intel";
      disks = {
        boot = "";
        data = [ ];
      };
    };
    virtualization.guestAgent.enable = true;
  };

  cpu-worker-1 = {
    staticIPv4 = "192.168.100.161";
    role = "cpu-worker";
    hardware = {
      cpu.vendor = "intel";
      disks = {
        boot = "";
        data = [ ];
      };
    };
    virtualization.guestAgent.enable = true;
  };

  gpu-worker-1 = {
    staticIPv4 = "192.168.100.162";
    role = "gpu-worker";
    hardware = {
      cpu.vendor = "intel";
      disks = {
        boot = "";
        data = [ ];
      };
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
      guestAgent.enable = true;
      bridge = {
        enable = true;
        name = "br0";
      };
    };
    power.nvidia = {
      persistenced = true;
      powerManagement = true;
    };
    storage.scratch.paths = [
      "/srv"
      "/var/lib/libvirt/images"
      "/var/lib/gpu-workloads"
    ];
  };
}
