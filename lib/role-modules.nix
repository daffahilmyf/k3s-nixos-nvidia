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

  vm-host = [
    ../profiles/roles/vm-host.nix
  ];

  gpu-vm-host = [
    ../profiles/roles/gpu-vm-host.nix
    ../profiles/hardware/nvidia.nix
  ];

  storage-host = [
    ../profiles/roles/storage-host.nix
  ];
}
