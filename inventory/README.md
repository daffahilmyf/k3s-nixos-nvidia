# Inventory

Declarative cluster inventory.

- `nodes.nix`: hostnames, roles, and per-node static IPv4 addresses.
- `network.nix`: shared LAN defaults applied to static nodes.

Keep facts about machines here. Keep reusable behavior in `modules/` or `profiles/`.
