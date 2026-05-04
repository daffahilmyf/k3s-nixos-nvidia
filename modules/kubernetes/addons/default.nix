{
  imports = [
    ./_manifest.nix
    ./cert-manager.nix
    ./ingress-nginx.nix
    ./local-path-storage.nix
    ./nvidia-device-plugin.nix
  ];
}
