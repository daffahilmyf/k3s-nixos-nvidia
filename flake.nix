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
          ;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = nixpkgs.lib.mapAttrs mkNode nodes;
    };
}
