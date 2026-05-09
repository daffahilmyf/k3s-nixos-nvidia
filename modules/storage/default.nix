{
  infraInventory,
  lib,
  nodeInventory,
  pkgs,
  ...
}:

let
  global = infraInventory.storage or { };
  local = nodeInventory.storage or { };
  cfg = global // local;
  btrfs = (global.btrfs or { }) // (local.btrfs or { });
  zfs = (global.zfs or { }) // (local.zfs or { });
  scratch = (global.scratch or { }) // (local.scratch or { });
  scratchPaths = scratch.paths or [ ];
in

{
  config = lib.mkIf (cfg.enable or false) {
    boot.supportedFilesystems = lib.mkIf (zfs.enable or false) [ "zfs" ];
    boot.zfs.forceImportRoot = lib.mkIf (zfs.enable or false) false;

    services.fstrim.enable = cfg.fstrim.enable or true;

    systemd.tmpfiles.rules = lib.mkIf (scratch.enable or false) (
      map (path: "d ${path} 0755 root root - -") scratchPaths
    );

    environment.systemPackages =
      with pkgs;
      [
        cryptsetup
        hdparm
        parted
        xfsprogs
      ]
      ++ lib.optionals (btrfs.enable or false) [
        btrfs-progs
        compsize
      ]
      ++ lib.optionals (zfs.enable or false) [
        sanoid
        zfs
      ];
  };
}
