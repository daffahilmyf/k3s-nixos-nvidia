# Modules

Reusable NixOS modules imported by every host.

## Domains

- `core`: baseline operating system behavior for all nodes.
- `integrations`: glue for external module systems such as Home Manager and sops-nix.
- `kubernetes`: k3s cluster configuration and Kubernetes host requirements.
- `networking`: network stack, DNS, DHCP, and firewall defaults.
- `nix`: Nix daemon, flakes, trusted users, cache, and garbage collection settings.
- `security`: users, sudo, SSH, and access control.

## Rule of Thumb

Host-specific values belong in `hosts/<hostname>`.

Reusable behavior belongs here.

Role-specific behavior belongs in `profiles/roles`.

Hardware-specific behavior belongs in `profiles/hardware`.
