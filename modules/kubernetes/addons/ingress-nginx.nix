{ kubernetesInventory, lib, ... }:

let
  cfg = kubernetesInventory.addons.ingressNginx or { };
in

{
  options.homelab.kubernetes.addons.ingressNginx.enable = lib.mkEnableOption "ingress-nginx addon";

  config.homelab.kubernetes.addons.ingressNginx.enable = cfg.enable or false;
}
