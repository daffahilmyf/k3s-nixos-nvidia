# Bootstrap

This is the intended first-cluster bootstrap flow.

## 1. Prepare Inventory

Check these files before installing any node:

```sh
inventory/nodes.nix
inventory/network.nix
inventory/system.nix
inventory/kubernetes.nix
inventory/users.nix
```

Make sure each host has:

- a matching `hosts/<hostname>` directory
- a static IPv4 address
- the correct role
- reachable DNS or `/etc/hosts` entries for `*.home.arpa`

## 2. Generate Hardware Configs

On each target node:

```sh
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

Review disk labels and filesystem declarations before rebuilding.

## 3. Configure Secrets

Set real age public keys in `.sops.yaml`, then create host secret files.

At minimum, k3s nodes need the shared token secret configured by `inventory/kubernetes.nix`.

See `docs/secrets.md`.

## 4. Install Control Plane

Deploy the control-plane host first:

```sh
sudo nixos-rebuild switch --flake .#control-plane
```

Check k3s:

```sh
sudo systemctl status k3s --no-pager
sudo k3s kubectl get nodes -o wide
```

## 5. Install Workers

Deploy CPU and GPU workers after the control plane is healthy:

```sh
sudo nixos-rebuild switch --flake .#cpu-worker-1
sudo nixos-rebuild switch --flake .#gpu-worker-1
```

From the repo dev shell:

```sh
nix develop
homelab kubectl get nodes -o wide
homelab status cpu-worker-1 k3s
homelab status gpu-worker-1 k3s
```

## 6. Apply Add-ons

Add-ons are intentionally separate from base k3s. Enable them in `inventory/kubernetes.nix` after the base cluster is stable.

Suggested order:

1. NVIDIA device plugin, if GPU workloads are needed. This is currently enabled in `inventory/kubernetes.nix`.
2. Load balancer or ingress.
3. cert-manager.
4. Storage.
5. Observability.

## Recovery Notes

Before changing core k3s settings, test with:

```sh
homelab dry-build control-plane
homelab dry-build cpu-worker-1
homelab dry-build gpu-worker-1
```

If a worker fails to join, check:

```sh
homelab logs <node> k3s
homelab ping control-plane
homelab kubectl get nodes -o wide
```
