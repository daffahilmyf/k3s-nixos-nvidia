{
  config,
  lib,
  networkInventory,
  nodeInventory,
  staticNodes,
  ...
}:

let
  cfg = config.homelab.network.static;
  bridge = nodeInventory.virtualization.bridge or { };
  bridgeEnabled = bridge.enable or false;
  bridgeName = bridge.name or "br0";
  domain = networkInventory.domain or null;
  hostAliases = networkInventory.hostAliases or { };
  nodeNetwork = nodeInventory.network or { };
  routes = nodeNetwork.routes or [ ];

  namesFor = hostname: [ hostname ] ++ lib.optional (domain != null) "${hostname}.${domain}";

  nodeHosts = lib.mapAttrs' (hostname: address: {
    name = address;
    value = namesFor hostname;
  }) staticNodes;

  aliasHosts = lib.mapAttrs (
    _: aliases:
    lib.unique (aliases ++ lib.optionals (domain != null) (map (alias: "${alias}.${domain}") aliases))
  ) hostAliases;
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
      domain = lib.mkIf (domain != null) domain;
      firewall.enable = true;
      hosts = nodeHosts // aliasHosts;
    };

    systemd.network = {
      enable = true;
      netdevs = lib.mkIf bridgeEnabled {
        "10-${bridgeName}" = {
          netdevConfig = {
            Kind = "bridge";
            Name = bridgeName;
          };
        };
      };
      networks =
        if bridgeEnabled then
          {
            "10-lan-uplink" = {
              matchConfig.Name = if cfg.enable then cfg.interface else "en* eth*";
              networkConfig = {
                Bridge = bridgeName;
                DHCP = "no";
                IPv6AcceptRA = false;
              };
            };
            "20-${bridgeName}" = {
              matchConfig.Name = bridgeName;
              address = lib.mkIf cfg.enable [
                "${cfg.address}/${toString cfg.prefixLength}"
              ];
              gateway = lib.mkIf cfg.enable [
                cfg.gateway
              ];
              dns = lib.mkIf cfg.enable cfg.dns;
              inherit routes;
              networkConfig = {
                DHCP = if cfg.enable then "no" else "ipv4";
                IPv6AcceptRA = true;
              };
            };
          }
        else
          {
            "10-lan" = {
              matchConfig.Name = if cfg.enable then cfg.interface else "en* eth*";
              address = lib.mkIf cfg.enable [
                "${cfg.address}/${toString cfg.prefixLength}"
              ];
              gateway = lib.mkIf cfg.enable [
                cfg.gateway
              ];
              dns = lib.mkIf cfg.enable cfg.dns;
              inherit routes;
              networkConfig = {
                DHCP = if cfg.enable then "no" else "ipv4";
                IPv6AcceptRA = true;
              };
            };
          };
    };

    services.resolved.enable = true;
  };
}
