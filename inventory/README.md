# Inventory

Declarative cluster inventory.

- `nodes.nix`: hostnames, roles, and per-node static IPv4 addresses.
- `network.nix`: shared LAN defaults, domain, and the Kubernetes API endpoint.
- `kubernetes.nix`: cluster-wide Kubernetes settings such as the k3s package.

Keep facts about machines here. Keep reusable behavior in `modules/` or `profiles/`.
