{
  inputs,
  nixpkgs,
  home-manager,
  sops-nix,
  system,
  username,
  lan,
  nodes,
}:

let
  roleModules = import ./role-modules.nix;

  staticNodes = nixpkgs.lib.mapAttrs (_: node: node.staticIPv4) (
    nixpkgs.lib.filterAttrs (_: node: node ? staticIPv4) nodes
  );

  modulesForRole =
    role:
    roleModules.${role} or (throw "Unknown node role '${role}'. Add it to lib/role-modules.nix.");
in

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
    ../modules
    ../hosts/${hostname}
  ]
  ++ nixpkgs.lib.optional (node ? staticIPv4) {
    homelab.network.static = lan // {
      enable = true;
      address = node.staticIPv4;
    };
  }
  ++ modulesForRole node.role;
}
