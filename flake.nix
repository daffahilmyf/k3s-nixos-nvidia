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
            ./hosts/${hostname}
          ] ++ extraModules;
        };

      mkControlPlane = hostname: mkNode {
        inherit hostname;
        role = "control-plane";
      };

      mkDefaultHost = hostname: mkNode {
        inherit hostname;
        role = "default";
      };

      mkCpuWorker = hostname: mkNode {
        inherit hostname;
        role = "cpu-worker";
      };

      mkGpuWorker = hostname: mkNode {
        inherit hostname;
        role = "gpu-worker";
      };
    in
    {
      nixosConfigurations = {
        default = mkDefaultHost "default";

        control-plane = mkControlPlane "control-plane";

        cpu-worker-1 = mkCpuWorker "cpu-worker-1";

        gpu-worker-1 = mkGpuWorker "gpu-worker-1";
      };
    };
}
