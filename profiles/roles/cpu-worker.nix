{
  homelab.role = "cpu-worker";

  homelab.k3s = {
    enable = true;
    role = "agent";
    nodeLabels = [
      "homelab.local/role=cpu-worker"
    ];
  };
}
