{ kubernetesInventory, lib, ... }:

let
  cfg = kubernetesInventory.addons.storage.localPath or { };
in

{
  options.homelab.kubernetes.addons.localPathStorage.enable =
    lib.mkEnableOption "k3s local-path storage addon";

  config.homelab.kubernetes.addons.localPathStorage.enable = cfg.enable or true;
}
