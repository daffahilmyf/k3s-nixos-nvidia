# CI

GitHub Actions runs Nix checks in `.github/workflows/nix.yml`.

## Actions Used

- `cachix/install-nix-action`: installs Nix on the GitHub runner.
- `DeterminateSystems/magic-nix-cache-action`: caches Nix store paths through GitHub Actions cache.
- `DeterminateSystems/flake-checker-action`: checks flake input health.

## Jobs

- `lint`: checks formatting and runs `statix`.
- `flake-check`: runs `nix flake check`.
- `build-hosts`: builds every NixOS system closure with `nix build --no-link`.
- `flake-health`: checks whether flake inputs are healthy.

The build job does not install NixOS. It only builds the system closure for each host.

Magic Nix Cache is zero-configuration and does not require a Cachix account or repository secret. It is useful for CI-to-CI reuse; it is not a public binary cache for your machines.

`flake-health` is informational until `flake.lock` is committed. After that, set `fail-mode: true` in the workflow if you want stale or unsupported nixpkgs inputs to fail CI.

## Local Equivalent

```sh
nix fmt -- --check .
nix run nixpkgs#statix -- check .
nix flake check --print-build-logs
nix build --no-link .#nixosConfigurations.control-plane.config.system.build.toplevel
```
