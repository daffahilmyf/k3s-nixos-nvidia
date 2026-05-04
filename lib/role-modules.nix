{
  default = [
    ../profiles/roles/default.nix
  ];

  control-plane = [
    ../profiles/roles/control-plane.nix
  ];

  cpu-worker = [
    ../profiles/roles/cpu-worker.nix
  ];

  gpu-worker = [
    ../profiles/roles/gpu-worker.nix
    ../profiles/hardware/nvidia.nix
  ];
}
