{ kubernetesInventory, lib, ... }:

let
  cfg = kubernetesInventory.addons.traefik or { };
in

{
  options.homelab.kubernetes.addons.traefik = {
    enable = lib.mkEnableOption "Traefik ingress controller addon";

    namespace = lib.mkOption {
      type = lib.types.str;
      default = "traefik";
      description = "Namespace where Traefik should be installed.";
    };
  };

  config.homelab.kubernetes.addons.traefik = {
    enable = cfg.enable or false;
    namespace = cfg.namespace or "traefik";
  };
}
