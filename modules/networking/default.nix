{
  config,
  lib,
  staticNodes,
  ...
}:

let
  cfg = config.homelab.network.static;
in

{
  options.homelab.network.static = {
    enable = lib.mkEnableOption "static network configuration";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "en* eth*";
      description = "systemd-networkd interface match for the LAN interface.";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Static IPv4 address for this host.";
    };

    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "IPv4 network prefix length.";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Default IPv4 gateway.";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "DNS servers for this host.";
    };
  };

  config = {
    networking = {
      useDHCP = false;
      useNetworkd = true;
      firewall.enable = true;
      hosts = lib.mapAttrs' (hostname: address: {
        name = address;
        value = [ hostname ];
      }) staticNodes;
    };

    systemd.network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = if cfg.enable then cfg.interface else "en* eth*";
        address = lib.mkIf cfg.enable [
          "${cfg.address}/${toString cfg.prefixLength}"
        ];
        gateway = lib.mkIf cfg.enable [
          cfg.gateway
        ];
        dns = lib.mkIf cfg.enable cfg.dns;
        networkConfig = {
          DHCP = if cfg.enable then "no" else "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };

    services.resolved.enable = true;
  };
}
