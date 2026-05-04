# Library

Small helpers used by `flake.nix`.

- `mk-node.nix`: builds one `nixosSystem` from an inventory node.
- `role-modules.nix`: maps inventory roles to profile modules.

This keeps `flake.nix` focused on composition instead of host-building details.
