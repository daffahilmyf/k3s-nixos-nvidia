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

      mkNode =
        {
          hostname,
          role,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username hostname role;
          };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./modules/system
            ./hosts/${hostname}
          ] ++ extraModules;
        };

      mkControlPlane = hostname: mkNode {
        inherit hostname;
        role = "control-plane";
        extraModules = [
          ./profiles/roles/control-plane.nix
        ];
      };

      mkDefaultHost = hostname: mkNode {
        inherit hostname;
        role = "default";
        extraModules = [
          ./profiles/roles/default.nix
        ];
      };

      mkCpuWorker = hostname: mkNode {
        inherit hostname;
        role = "cpu-worker";
        extraModules = [
          ./profiles/roles/cpu-worker.nix
        ];
      };

      mkGpuWorker = hostname: mkNode {
        inherit hostname;
        role = "gpu-worker";
        extraModules = [
          ./profiles/roles/gpu-worker.nix
          ./profiles/hardware/nvidia.nix
        ];
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = {
        default = mkDefaultHost "default";

        control-plane = mkControlPlane "control-plane";

        cpu-worker-1 = mkCpuWorker "cpu-worker-1";

        gpu-worker-1 = mkGpuWorker "gpu-worker-1";
      };
    };
}
