{
  config,
  lib,
  ...
}:

{
  options.homelab.kubernetes.manifests = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = { };
    description = "Static Kubernetes manifests written to the k3s manifests directory.";
  };

  config = lib.mkIf (config.homelab.k3s.enable && config.homelab.k3s.role == "server") {
    environment.etc = lib.mapAttrs' (name: text: {
      name = "rancher/k3s/server/manifests/${name}.yaml";
      value.text = text;
    }) config.homelab.kubernetes.manifests;
  };
}
