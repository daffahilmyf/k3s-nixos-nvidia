# Secrets

Secrets are managed with `sops-nix`.

## Age Keys

Each node uses the age key path configured by `inventory/system.nix`:

```nix
sopsAgeKeyFile = "/var/lib/sops-nix/key.txt";
```

Replace placeholder keys in `.sops.yaml` with real age public keys.

## Host Secret Files

Create one encrypted file per host:

```sh
sops secrets/control-plane.yaml
sops secrets/cpu-worker-1.yaml
sops secrets/gpu-worker-1.yaml
```

## Schema

The k3s token secret name comes from `inventory/kubernetes.nix`:

```nix
k3s.token.secretName = "k3s-token";
```

Expected YAML shape:

```yaml
k3s-token: "replace-with-shared-cluster-token"
```

Use the same shared k3s token for every k3s node.

## Token Generation

Generate a token locally:

```sh
openssl rand -hex 32
```

Then write it to every k3s node secret file using the configured secret name.

## Operational Checks

Check whether sops-nix created the runtime secret:

```sh
sudo ls -l /run/secrets
sudo systemctl status sops-nix --no-pager
```

Check k3s token usage:

```sh
sudo systemctl cat k3s
sudo journalctl -u k3s -n 100 --no-pager
```
