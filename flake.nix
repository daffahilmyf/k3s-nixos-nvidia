{
  description = "Homelab NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "daffa";
      pkgs = nixpkgs.legacyPackages.${system};
      lan = {
        interface = "en* eth*";
        prefixLength = 24;
        gateway = "192.168.100.1";
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };

      nodes = {
        default = {
          role = "default";
        };

        control-plane = {
          staticIPv4 = "192.168.100.155";
          role = "control-plane";
        };

        cpu-worker-1 = {
          staticIPv4 = "192.168.100.156";
          role = "cpu-worker";
        };

        gpu-worker-1 = {
          staticIPv4 = "192.168.100.157";
          role = "gpu-worker";
        };
      };

      roleModules = {
        default = [
          ./profiles/roles/default.nix
        ];
        control-plane = [
          ./profiles/roles/control-plane.nix
        ];
        cpu-worker = [
          ./profiles/roles/cpu-worker.nix
        ];
        gpu-worker = [
          ./profiles/roles/gpu-worker.nix
          ./profiles/hardware/nvidia.nix
        ];
      };

      staticNodes = nixpkgs.lib.mapAttrs (_: node: node.staticIPv4) (
        nixpkgs.lib.filterAttrs (_: node: node ? staticIPv4) nodes
      );

      mkNode =
        hostname:
        node:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username hostname staticNodes;
            inherit (node) role;
          };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./modules
            ./hosts/${hostname}
          ]
          ++ nixpkgs.lib.optional (node ? staticIPv4) {
            homelab.network.static = lan // {
              enable = true;
              address = node.staticIPv4;
            };
          }
          ++ roleModules.${node.role};
        };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = nixpkgs.lib.mapAttrs mkNode nodes;
    };
}
