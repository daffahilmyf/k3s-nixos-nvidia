{
  config,
  lib,
  ...
}:

let
  etcManifestDir = "/etc/rancher/k3s/server/manifests";
  k3sManifestDir = "/var/lib/rancher/k3s/server/manifests";
  installManifests = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: _:
      ''install -Dm0644 "${etcManifestDir}/${name}.yaml" "${k3sManifestDir}/${name}.yaml"''
    ) config.homelab.kubernetes.manifests
  );
in

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

    systemd.services.k3s.preStart = ''
      mkdir -p "${k3sManifestDir}"
      ${installManifests}
    '';
  };
}
