# Inventory

Declarative cluster inventory.

- `nodes.nix`: hostnames, roles, and per-node static IPv4 addresses.
- `nodes.nix`: also owns per-node hardware, GPU, IOMMU, VFIO, and virtualization facts.
- `network.nix`: shared LAN defaults, domain, and the Kubernetes API endpoint.
- `security.nix`: shared SSH and sudo hardening defaults.
- `kubernetes.nix`: cluster-wide Kubernetes settings such as the k3s package and add-on toggles.
- `system.nix`: shared system defaults such as state version, timezone, editor, and flake path.
- `users.nix`: user inventory, including the primary admin user.

Keep facts about machines here. Keep reusable behavior in `modules/` or `profiles/`.
