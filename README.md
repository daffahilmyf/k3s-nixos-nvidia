# Homelab NixOS Config

Flake-based NixOS configuration for CLI-only homelab nodes.

## Hosts

- `default`: simple generic host for experiments or one-off machines.
- `control-plane`: control-plane server at `192.168.100.155`.
- `cpu-worker-1`: CPU-only worker node at `192.168.100.156`.
- `gpu-worker-1`: NVIDIA worker node at `192.168.100.157`.

Build or switch a host from the target machine:

```sh
sudo nixos-rebuild switch --flake .#control-plane
sudo nixos-rebuild switch --flake .#cpu-worker-1
sudo nixos-rebuild switch --flake .#gpu-worker-1
```

## CLI

Enter the development shell to get the generated `homelab` command with Bash completion:

```sh
nix develop
```

Useful commands:

```sh
homelab nodes
homelab ssh control-plane
homelab ping cpu-worker-1
homelab routes gpu-worker-1
homelab status gpu-worker-1 k3s
homelab logs control-plane k3s
homelab exporter gpu-worker-1
homelab kubectl get nodes -o wide
homelab dry-build cpu-worker-1
homelab rebuild gpu-worker-1 switch
```

## Layout

```text
flake.nix
inventory/
lib/
hosts/
  control-plane/
  cpu-worker-1/
  default/
  gpu-worker-1/
modules/
  core/
  integrations/
  kubernetes/
  networking/
  nix/
  security/
profiles/
  hardware/
  roles/
home/
  users/
secrets/
```

- `hosts/<hostname>` contains host-specific hardware and hostname wiring.
- `inventory` contains node facts such as role and static IP address.
- `inventory/network.nix` contains LAN settings, the `home.arpa` domain, and the Kubernetes API endpoint.
- `inventory/kubernetes.nix` contains cluster-wide Kubernetes settings such as the k3s package.
- `inventory/infra.nix` contains shared host infrastructure defaults such as storage, backups, Tailscale, observability, power, and recovery.
- `inventory/security.nix` contains SSH and sudo hardening defaults.
- `inventory/system.nix` contains shared system defaults.
- `inventory/users.nix` contains user inventory.
- `lib` contains flake helper functions and role-to-profile mapping.
- `modules` contains shared NixOS modules used by every host.
- `modules/core` contains base OS defaults, boot, locale, and common CLI packages.
- `modules/integrations` wires external NixOS modules such as Home Manager and sops-nix.
- `modules/kubernetes` contains k3s configuration and Kubernetes host requirements.
- `modules/networking` contains networkd, DHCP, DNS, and firewall defaults.
- `modules/nix` contains Nix daemon, flakes, trusted users, and garbage collection settings.
- `modules/backup`, `modules/storage`, `modules/remote-access`, `modules/observability`, and `modules/power` contain reusable host infrastructure modules.
- `modules/security` contains SSH, sudo, and user configuration.
- `profiles/roles` contains role-specific configuration.
- `profiles/hardware` contains hardware-specific configuration such as NVIDIA.
- `home/users` contains CLI-only Home Manager configuration.
- `secrets` is reserved for encrypted `sops-nix` files.

## Adding Nodes

Add a CPU worker by creating `hosts/cpu-worker-2` and adding it to `inventory/nodes.nix`:

```nix
cpu-worker-2 = {
  staticIPv4 = "192.168.100.158";
  role = "cpu-worker";
};
```

Add an NVIDIA worker the same way:

```nix
gpu-worker-2 = {
  staticIPv4 = "192.168.100.159";
  role = "gpu-worker";
};
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

Each node generates its local age key at the path configured in `inventory/system.nix`.

For k3s nodes, include the shared cluster token using the secret name from `inventory/kubernetes.nix`.

## Kubernetes

Role profiles enable k3s automatically:

- `control-plane`: k3s server with embedded etcd cluster initialization.
- `cpu-worker-1`: k3s agent.
- `gpu-worker-1`: k3s agent with NVIDIA container toolkit, GPU labels, and a GPU taint.

The k3s module disables bundled components listed in `inventory/kubernetes.nix` so Traefik ingress and load balancing can be installed explicitly later.

Static node records are generated as both short names and `home.arpa` names, for example `control-plane` and `control-plane.home.arpa`.

The Kubernetes API endpoint defaults to `https://control-plane.home.arpa:6443`.

The k3s package is selected in `inventory/kubernetes.nix`, currently as `pkgs.k3s` from the pinned nixpkgs input so all nodes use the same version.

The k3s token secret name, fallback token file, and disabled bundled components are also configured in `inventory/kubernetes.nix`.

More detail:

- `docs/bootstrap.md`
- `docs/ci.md`
- `docs/secrets.md`
- `docs/gpu-node.md`
- `docs/infra.md`
- `docs/system-gpu-vm.md`
