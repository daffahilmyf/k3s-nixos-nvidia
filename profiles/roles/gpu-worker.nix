{
  homelab.role = "gpu-worker";

  homelab.k3s = {
    enable = true;
    role = "agent";
    nodeLabels = [
      "homelab.local/role=gpu-worker"
      "homelab.local/gpu=nvidia"
    ];
    nodeTaints = [
      "homelab.local/gpu=nvidia:NoSchedule"
    ];
  };
}
