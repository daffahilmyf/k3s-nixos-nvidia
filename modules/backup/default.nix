{
  config,
  infraInventory,
  lib,
  nodeInventory,
  pkgs,
  ...
}:

let
  global = infraInventory.backup or { };
  local = nodeInventory.backup or { };
  cfg = global // local;
  passwordSecretName = cfg.passwordSecretName or "restic-password";
  useSopsSecret = (cfg.useSopsSecret or true) && passwordSecretName != "";
in

{
  config = lib.mkIf (cfg.enable or false) {
    sops.secrets = lib.mkIf useSopsSecret {
      ${passwordSecretName} = { };
    };

    services.restic.backups.homelab = {
      initialize = cfg.initialize or true;
      inherit (cfg) repository;
      passwordFile =
        cfg.passwordFile or (
          if useSopsSecret then
            config.sops.secrets.${passwordSecretName}.path
          else
            "/run/secrets/restic-password"
        );
      paths = cfg.paths or [ "/etc/nixos" ];
      exclude = cfg.exclude or [ ];
      pruneOpts =
        cfg.pruneOpts or [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
      timerConfig =
        cfg.timerConfig or {
          OnCalendar = "03:30";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
    };

    environment.systemPackages = with pkgs; [
      restic
    ];
  };
}
