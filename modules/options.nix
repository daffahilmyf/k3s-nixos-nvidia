{ lib, ... }:

{
  options.homelab.role = lib.mkOption {
    type = lib.types.enum [
      "default"
      "control-plane"
      "cpu-worker"
      "gpu-worker"
      "gpu-vm-host"
      "storage-host"
      "vm-host"
    ];
    default = "default";
    description = "Logical role for this homelab node.";
  };
}
