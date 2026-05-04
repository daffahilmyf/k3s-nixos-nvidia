{ lib, ... }:

{
  options.homelab.role = lib.mkOption {
    type = lib.types.enum [
      "default"
      "control-plane"
      "cpu-worker"
      "gpu-worker"
    ];
    default = "default";
    description = "Logical role for this homelab node.";
  };
}
