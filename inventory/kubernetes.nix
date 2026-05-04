{ pkgs }:

{
  k3s = {
    # Keep all nodes on the same k3s package from the pinned nixpkgs input.
    # Change this in one place if you want to pin another package later.
    package = pkgs.k3s;
  };
}
