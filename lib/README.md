# Library

Small helpers used by `flake.nix`.

- `mk-node.nix`: builds one `nixosSystem` from an inventory node.
- `role-modules.nix`: maps inventory roles to profile modules.
- `homelab-cli.nix`: generates the `homelab` debug CLI and Bash completion from inventory.

This keeps `flake.nix` focused on composition instead of host-building details.
