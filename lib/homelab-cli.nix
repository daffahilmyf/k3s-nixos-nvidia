{
  pkgs,
  lib,
  network,
  nodes,
  systemSettings,
}:

let
  staticNodes = lib.filterAttrs (_: node: node ? staticIPv4) nodes;
  nodeNames = lib.attrNames staticNodes;
  controlPlaneNames = lib.attrNames (
    lib.filterAttrs (_: node: node.role == "control-plane" && node ? staticIPv4) nodes
  );
  defaultControlPlane = if controlPlaneNames == [ ] then "" else lib.head controlPlaneNames;
  domain = network.domain or "home.arpa";
  flakePath = systemSettings.flakePath or "/etc/nixos";

  nodeList = lib.concatStringsSep " " nodeNames;
  commandList = lib.concatStringsSep " " [
    "addr"
    "dry-build"
    "help"
    "k3s"
    "kubectl"
    "logs"
    "nodes"
    "ping"
    "rebuild"
    "ssh"
    "status"
  ];

  nodeRows = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      hostname: node:
      ''printf "%-20s %-15s %-15s %s\n" "${hostname}" "${node.role}" "${node.staticIPv4}" "${hostname}.${domain}"''
    ) staticNodes
  );

  nodeCase = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (hostname: node: ''
      ${hostname})
        NODE_IP="${node.staticIPv4}"
        NODE_ROLE="${node.role}"
        NODE_FQDN="${hostname}.${domain}"
        ;;
    '') staticNodes
  );

  script = pkgs.writeShellScript "homelab" ''
    set -euo pipefail

    NODES="${nodeList}"
    DEFAULT_CONTROL_PLANE="${defaultControlPlane}"

    usage() {
      cat <<'USAGE'
    Usage:
      homelab nodes
      homelab addr NODE
      homelab ssh NODE [SSH_ARGS...]
      homelab ping NODE
      homelab status NODE [UNIT]
      homelab logs NODE [UNIT]
      homelab k3s NODE [K3S_ARGS...]
      homelab kubectl [KUBECTL_ARGS...]
      homelab rebuild NODE [switch|boot|test|dry-build]
      homelab dry-build NODE

    Common units:
      k3s, sshd, systemd-networkd, systemd-resolved
    USAGE
    }

    load_node() {
      local node="''${1:-}"
      case "$node" in
    ${nodeCase}
        *)
          echo "unknown node: $node" >&2
          echo "known nodes: $NODES" >&2
          exit 2
          ;;
      esac
    }

    require_node() {
      if [ "$#" -lt 1 ]; then
        echo "missing node" >&2
        usage >&2
        exit 2
      fi
      load_node "$1"
    }

    cmd="''${1:-help}"
    shift || true

    case "$cmd" in
      help|-h|--help)
        usage
        ;;

      nodes)
        printf "%-20s %-15s %-15s %s\n" "HOST" "ROLE" "IP" "FQDN"
    ${nodeRows}
        ;;

      addr)
        require_node "$@"
        printf "%s\n" "$NODE_IP"
        ;;

      ssh)
        require_node "$@"
        node="$1"
        shift
        exec ${pkgs.openssh}/bin/ssh "$node" "$@"
        ;;

      ping)
        require_node "$@"
        exec ${pkgs.iputils}/bin/ping -c 4 "$NODE_FQDN"
        ;;

      status)
        require_node "$@"
        node="$1"
        unit="''${2:-k3s}"
        exec ${pkgs.openssh}/bin/ssh "$node" systemctl status "$unit" --no-pager
        ;;

      logs)
        require_node "$@"
        node="$1"
        unit="''${2:-k3s}"
        exec ${pkgs.openssh}/bin/ssh "$node" journalctl -u "$unit" -n 200 -f
        ;;

      k3s)
        require_node "$@"
        node="$1"
        shift
        exec ${pkgs.openssh}/bin/ssh "$node" sudo k3s "$@"
        ;;

      kubectl)
        if [ -z "$DEFAULT_CONTROL_PLANE" ]; then
          echo "no control-plane node found in inventory" >&2
          exit 2
        fi
        exec ${pkgs.openssh}/bin/ssh "$DEFAULT_CONTROL_PLANE" sudo k3s kubectl "$@"
        ;;

      rebuild)
        require_node "$@"
        node="$1"
        action="''${2:-switch}"
        case "$action" in
          switch|boot|test|dry-build) ;;
          *)
            echo "unknown rebuild action: $action" >&2
            echo "valid actions: switch boot test dry-build" >&2
            exit 2
            ;;
        esac
        exec ${pkgs.openssh}/bin/ssh "$node" sudo nixos-rebuild "$action" --flake "${flakePath}#$node"
        ;;

      dry-build)
        require_node "$@"
        node="$1"
        exec ${pkgs.openssh}/bin/ssh "$node" sudo nixos-rebuild dry-build --flake "${flakePath}#$node"
        ;;

      *)
        echo "unknown command: $cmd" >&2
        usage >&2
        exit 2
        ;;
    esac
  '';

  completion = pkgs.writeText "homelab-completion" ''
    _homelab()
    {
      local cur prev words cword
      _init_completion || return

      local commands="${commandList}"
      local nodes="${nodeList}"
      local units="k3s sshd systemd-networkd systemd-resolved nix-daemon"
      local actions="switch boot test dry-build"

      if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return
      fi

      case "''${words[1]}" in
        addr|dry-build|k3s|logs|ping|rebuild|ssh|status)
          if [[ $cword -eq 2 ]]; then
            COMPREPLY=( $(compgen -W "$nodes" -- "$cur") )
            return
          fi
          ;;
      esac

      case "''${words[1]}" in
        logs|status)
          if [[ $cword -eq 3 ]]; then
            COMPREPLY=( $(compgen -W "$units" -- "$cur") )
            return
          fi
          ;;
        rebuild)
          if [[ $cword -eq 3 ]]; then
            COMPREPLY=( $(compgen -W "$actions" -- "$cur") )
            return
          fi
          ;;
      esac
    }

    complete -F _homelab homelab
  '';
in

pkgs.stdenvNoCC.mkDerivation {
  pname = "homelab-cli";
  version = "0.1.0";

  dontUnpack = true;

  installPhase = ''
    install -Dm755 ${script} "$out/bin/homelab"
    install -Dm644 ${completion} "$out/share/bash-completion/completions/homelab"
  '';
}
