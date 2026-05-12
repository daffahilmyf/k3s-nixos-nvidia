# Infrastructure Modules

Host infrastructure is configured from `inventory/infra.nix` and can be overridden per node in `inventory/nodes.nix`.

## Storage

`modules/storage` enables baseline disk tooling, periodic trim, optional Btrfs/ZFS tooling, and scratch directory creation. It intentionally does not partition or mount disks until real disk IDs are known.

Example per-node override:

```nix
storage.scratch.paths = [
  "/srv"
  "/var/lib/libvirt/images"
  "/var/lib/gpu-workloads"
];
```

## Backups

`modules/backup` uses Restic. It is disabled by default until a repository is configured.

```nix
backup = {
  enable = true;
  repository = "sftp:backup@nas:/backups/gpu-worker-1";
  passwordSecretName = "restic-password";
  paths = [
    "/etc/nixos"
    "/var/lib/libvirt"
  ];
};
```

The password file is managed through `sops-nix` by default.

## Remote Access

`modules/remote-access` supports Tailscale. It is disabled by default and reads its auth key from SOPS when enabled.

```nix
remoteAccess.tailscale = {
  enable = true;
  authKeySecretName = "tailscale-auth-key";
  useRoutingFeatures = "client";
};
```

## Observability

`modules/observability` installs host debugging tools and enables the Prometheus node exporter by default. The exporter port is not opened on the firewall unless `openFirewall = true`.

Useful CLI checks:

```sh
homelab exporter gpu-worker-1
homelab routes gpu-worker-1
homelab disks gpu-worker-1
homelab temps gpu-worker-1
```

## Recovery

`modules/recovery` keeps boot rollback history, journald retention, and enables serial console kernel parameters by default. A rescue SSH user can be enabled per node when needed.

## VM Hosts

Reusable VM host roles are available:

- `vm-host`
- `gpu-vm-host`
- `storage-host`

Use these roles for future non-Kubernetes infrastructure nodes.

## Proxmox Guests

Set this on nodes that run as Proxmox/QEMU guests so the Proxmox dashboard can read IP addresses and guest state:

```nix
virtualization.guestAgent.enable = true;
```

The option enables `services.qemuGuest` inside NixOS. Proxmox must also have the VM's `QEMU Guest Agent` option enabled.
