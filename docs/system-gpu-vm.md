# System GPU and VM Layer

This document covers the host and VM side of GPU homelab nodes. Kubernetes add-ons are separate.

## Inventory

System/VM behavior is configured per node in `inventory/nodes.nix`.

Example:

```nix
gpu-worker-1 = {
  staticIPv4 = "192.168.100.162";
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
```

## GPU Modes

`hardware.gpu.mode = "host-driver"` keeps the NVIDIA driver available to the host. This is the right mode for bare-metal workloads and Kubernetes GPU workloads.

`hardware.gpu.mode = "vfio-passthrough"` binds the GPU to `vfio-pci` for VM passthrough. In that mode, set PCI IDs:

```nix
hardware.gpu.vfio.pciIds = [
  "10de:2684"
  "10de:22ba"
];
```

Use:

```sh
homelab pci gpu-worker-1
```

to find IDs.

## IOMMU

Enable IOMMU with:

```nix
hardware.cpu.vendor = "intel";
hardware.iommu.enable = true;
```

Supported vendors:

- `intel`: adds `intel_iommu=on iommu=pt`
- `amd`: adds `amd_iommu=on iommu=pt`

Check groups:

```sh
homelab iommu gpu-worker-1
```

## Virtualization

`virtualization.enable = true` enables:

- libvirt
- QEMU/KVM
- swtpm
- VM helper packages
- `kvm` and `libvirtd` group membership for the primary user

## Bridge Networking

When `virtualization.bridge.enable = true`, static networking moves from the physical NIC to the bridge.

The physical NIC becomes the bridge uplink, and the host IP is configured on `br0`.

Check bridge state:

```sh
homelab virt gpu-worker-1
```

## Thermal and Disk Health

`hardware.thermal.enable = true` enables:

- `thermald`
- SMART monitoring
- `lm_sensors`
- `smartmontools`
- `nvme-cli`

Check:

```sh
homelab temps gpu-worker-1
homelab disks gpu-worker-1
```

## Remote Recovery

The repo keeps multiple systemd-boot generations using:

```nix
inventory/system.nix bootConfigurationLimit
```

Use these before risky changes:

```sh
homelab dry-build gpu-worker-1
homelab rebuild gpu-worker-1 test
```

Then switch only after the test boot is healthy:

```sh
homelab rebuild gpu-worker-1 switch
```
