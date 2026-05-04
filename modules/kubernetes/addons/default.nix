{
  imports = [
    ./_manifest.nix
    ./cert-manager.nix
    ./local-path-storage.nix
    ./nvidia-device-plugin.nix
    ./traefik.nix
  ];
}
