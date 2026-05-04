# Homelab CLI

The flake generates a `homelab` CLI from `inventory/nodes.nix`.

Start a shell with the command and Bash completion loaded:

```sh
nix develop
```

Run without entering the shell:

```sh
nix run .#homelab -- nodes
```

## Commands

```sh
homelab nodes
homelab addr NODE
homelab ssh NODE
homelab ping NODE
homelab gpu NODE
homelab pci NODE
homelab iommu NODE
homelab temps NODE
homelab disks NODE
homelab virt NODE
homelab status NODE [UNIT]
homelab logs NODE [UNIT]
homelab k3s NODE [K3S_ARGS...]
homelab kubectl [KUBECTL_ARGS...]
homelab rebuild NODE [switch|boot|test|dry-build]
homelab dry-build NODE
```

Completion includes command names, node names, common systemd units, and rebuild actions.
