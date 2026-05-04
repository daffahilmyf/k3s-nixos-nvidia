{ kubernetesInventory, lib, ... }:

let
  cfg = kubernetesInventory.addons.certManager or { };
in

{
  options.homelab.kubernetes.addons.certManager.enable = lib.mkEnableOption "cert-manager addon";

  config.homelab.kubernetes.addons.certManager.enable = cfg.enable or false;
}
