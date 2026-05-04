{
  homelab.role = "control-plane";

  homelab.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    nodeLabels = [
      "homelab.local/role=control-plane"
    ];
  };
}
