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
      lan = import ./inventory/network.nix;
      nodes = import ./inventory/nodes.nix;
      kubernetes = import ./inventory/kubernetes.nix { inherit pkgs; };
      homelabCli = import ./lib/homelab-cli.nix {
        inherit pkgs nodes;
        lib = nixpkgs.lib;
        network = lan;
      };
      mkNode = import ./lib/mk-node.nix {
        inherit
          inputs
          nixpkgs
          home-manager
          sops-nix
          system
          username
          lan
          nodes
          kubernetes
          ;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      packages.${system} = {
        homelab-cli = homelabCli;
        default = homelabCli;
      };

      apps.${system} = {
        homelab = {
          type = "app";
          program = "${homelabCli}/bin/homelab";
        };
        default = {
          type = "app";
          program = "${homelabCli}/bin/homelab";
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          bash-completion
          homelabCli
          kubectl
          kubernetes-helm
          openssh
        ];

        shellHook = ''
          source ${pkgs.bash-completion}/share/bash-completion/bash_completion
          source ${homelabCli}/share/bash-completion/completions/homelab
        '';
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs mkNode nodes;
    };
}
