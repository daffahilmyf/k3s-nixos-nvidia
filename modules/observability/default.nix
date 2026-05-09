{
  config,
  infraInventory,
  lib,
  nodeInventory,
  pkgs,
  ...
}:

let
  global = infraInventory.observability or { };
  local = nodeInventory.observability or { };
  cfg = global // local;
  nodeExporter = (global.exporters.node or { }) // (local.exporters.node or { });
in

{
  config = lib.mkIf (cfg.enable or false) {
    services.prometheus.exporters.node = lib.mkIf (nodeExporter.enable or true) {
      enable = true;
      enabledCollectors =
        nodeExporter.enabledCollectors or [
          "systemd"
          "processes"
          "diskstats"
          "filesystem"
          "netdev"
        ];
      port = nodeExporter.port or 9100;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (nodeExporter.openFirewall or false) [
      (nodeExporter.port or 9100)
    ];

    environment.systemPackages = with pkgs; [
      btop
      dool
      ethtool
      fio
      iftop
      iotop
      iperf3
      ipmitool
      lshw
      nethogs
      sysstat
    ];
  };
}
