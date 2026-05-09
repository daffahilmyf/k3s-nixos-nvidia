{
  config,
  infraInventory,
  lib,
  nodeInventory,
  pkgs,
  ...
}:

let
  global = infraInventory.remoteAccess.tailscale or { };
  local = nodeInventory.remoteAccess.tailscale or { };
  cfg = global // local;
  authKeySecretName = cfg.authKeySecretName or "tailscale-auth-key";
  useSopsSecret = (cfg.useSopsSecret or true) && authKeySecretName != "";
in

{
  config = lib.mkIf (cfg.enable or false) {
    sops.secrets = lib.mkIf useSopsSecret {
      ${authKeySecretName} = { };
    };

    services.tailscale = {
      enable = true;
      openFirewall = cfg.openFirewall or true;
      useRoutingFeatures = cfg.useRoutingFeatures or "client";
      authKeyFile =
        cfg.authKeyFile or (
          if useSopsSecret then
            config.sops.secrets.${authKeySecretName}.path
          else
            "/run/secrets/tailscale-auth-key"
        );
      extraUpFlags = cfg.extraUpFlags or [ ];
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
