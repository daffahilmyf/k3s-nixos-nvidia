{ pkgs }:

{
  k3s = {
    # Keep all nodes on the same k3s package from the pinned nixpkgs input.
    # Change this in one place if you want to pin another package later.
    package = pkgs.k3s;
    disabledComponents = [
      "servicelb"
      "traefik"
    ];
    token = {
      secretName = "k3s-token";
      fallbackFile = "/run/secrets/k3s-token";
    };
  };

  addons = {
    certManager.enable = false;
    ingressNginx.enable = false;
    nvidiaDevicePlugin = {
      enable = true;
      image = "nvcr.io/nvidia/k8s-device-plugin:v0.19.0";
    };
    storage = {
      localPath.enable = true;
    };
  };
}
