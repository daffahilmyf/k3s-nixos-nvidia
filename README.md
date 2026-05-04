# Homelab NixOS Config

Flake-based NixOS configuration for CLI-only homelab nodes.

## Hosts

- `default`: simple generic host for experiments or one-off machines.
- `control-plane`: control-plane server.
- `cpu-worker-1`: CPU-only worker node.
- `gpu-worker-1`: NVIDIA worker node.

Build or switch a host from the target machine:

```sh
sudo nixos-rebuild switch --flake .#control-plane
sudo nixos-rebuild switch --flake .#cpu-worker-1
sudo nixos-rebuild switch --flake .#gpu-worker-1
```

## Layout

```text
flake.nix
hosts/
  control-plane/
  cpu-worker-1/
  default/
  gpu-worker-1/
modules/
  system/
profiles/
  hardware/
  roles/
home/
  users/
secrets/
```

- `hosts/<hostname>` contains host-specific hardware and hostname wiring.
- `modules/system` contains shared NixOS defaults used by every host.
- `profiles/roles` contains role-specific configuration.
- `profiles/hardware` contains hardware-specific configuration such as NVIDIA.
- `home/users` contains CLI-only Home Manager configuration.
- `secrets` is reserved for encrypted `sops-nix` files.

## Adding Nodes

Add a CPU worker by creating `hosts/cpu-worker-2` and adding it in `flake.nix`:

```nix
cpu-worker-2 = mkCpuWorker "cpu-worker-2";
```

Add an NVIDIA worker the same way:

```nix
gpu-worker-2 = mkGpuWorker "gpu-worker-2";
```

Generate real hardware config on the target machine:

```sh
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

## Secrets

Replace placeholder age keys in `.sops.yaml`, then create encrypted per-host files:

```sh
sops secrets/control-plane.yaml
sops secrets/cpu-worker-1.yaml
sops secrets/gpu-worker-1.yaml
```

Each node generates its local age key at `/var/lib/sops-nix/key.txt`.
