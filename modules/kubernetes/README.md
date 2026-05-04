# Kubernetes Modules

This domain configures k3s and the host settings Kubernetes expects.

## k3s

`k3s.nix` provides `homelab.k3s.*` options and maps them to NixOS `services.k3s`.

Included host requirements:

- kernel modules: `br_netfilter`, `overlay`, and IPVS modules
- sysctls: bridge netfilter, IPv4 forwarding, and IPv6 forwarding
- firewall ports:
  - `6443/tcp` for the Kubernetes API server
  - `2379/tcp` and `2380/tcp` for embedded etcd on server nodes
  - `10250/tcp` for kubelet
  - `8472/udp` for Flannel VXLAN
- CLI tools: `k3s`, `kubectl`, and `helm`

## Secrets

If `secrets/<hostname>.yaml` exists, this module expects a `k3s-token` secret and passes it to k3s.

If no host secret file exists:

- server nodes let k3s generate a token
- agent nodes expect a token file at `/run/secrets/k3s-token`

For reproducible cluster rebuilds, prefer storing the shared token in sops for every k3s node.

## API Endpoint

Agent nodes use `inventory/network.nix` value `kubernetes.apiServer` as their default server URL.

The current inventory points agents at `https://control-plane.home.arpa:6443`.
