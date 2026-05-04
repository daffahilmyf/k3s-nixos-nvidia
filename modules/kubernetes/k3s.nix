{
  config,
  kubernetesInventory,
  lib,
  networkInventory,
  pkgs,
  ...
}:

let
  cfg = config.homelab.k3s;
  inventoryK3s = kubernetesInventory.k3s or { };
  tokenSecretName = inventoryK3s.token.secretName or "k3s-token";
  isServer = cfg.role == "server";
  isAgent = cfg.role == "agent";
  defaultServerAddr = networkInventory.kubernetes.apiServer or "https://control-plane.home.arpa:6443";
  sopsFile = ../../secrets + "/${config.networking.hostName}.yaml";
  hasHostSecrets = builtins.pathExists sopsFile;
in

{
  options.homelab.k3s = {
    enable = lib.mkEnableOption "k3s Kubernetes node";

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "agent"
      ];
      default = "agent";
      description = "k3s role for this node.";
    };

    clusterInit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Initialize the first k3s server with embedded etcd.";
    };

    serverAddr = lib.mkOption {
      type = lib.types.str;
      default = defaultServerAddr;
      description = "k3s API server URL used by agent nodes.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = inventoryK3s.token.fallbackFile or "/run/secrets/k3s-token";
      description = "Path to the shared k3s cluster token.";
    };

    disable = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = inventoryK3s.disabledComponents or [ ];
      description = "Packaged k3s components to disable.";
    };

    nodeLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Node labels applied when the node first joins the cluster.";
    };

    nodeTaints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Node taints applied when the node first joins the cluster.";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags passed to k3s.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inventoryK3s.package or pkgs.k3s;
      defaultText = "inventory/kubernetes.nix k3s.package or pkgs.k3s";
      description = "k3s package used by all configured k3s nodes.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(isAgent && cfg.serverAddr == "");
        message = "homelab.k3s.serverAddr must be set for k3s agent nodes.";
      }
    ];

    environment.systemPackages = with pkgs; [
      cfg.package
      kubectl
      kubernetes-helm
    ];

    sops.secrets = lib.mkIf hasHostSecrets {
      ${tokenSecretName} = { };
    };

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    boot.kernelModules = [
      "br_netfilter"
      "ip_vs"
      "ip_vs_rr"
      "ip_vs_wrr"
      "ip_vs_sh"
      "overlay"
    ];

    services.k3s = {
      enable = true;
      inherit (cfg) package role;
      clusterInit = isServer && cfg.clusterInit;
      disable = lib.mkIf isServer cfg.disable;
      serverAddr = lib.mkIf isAgent cfg.serverAddr;
      tokenFile = lib.mkIf (hasHostSecrets || isAgent) (
        if hasHostSecrets then config.sops.secrets.${tokenSecretName}.path else cfg.tokenFile
      );
      nodeLabel = cfg.nodeLabels;
      nodeTaint = cfg.nodeTaints;
      inherit (cfg) extraFlags;
    };

    networking.firewall = {
      allowedTCPPorts = [
        10250
      ]
      ++ lib.optionals isServer [
        6443
        2379
        2380
      ];

      allowedUDPPorts = [
        8472
      ];
    };
  };
}
