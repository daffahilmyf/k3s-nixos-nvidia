# GPU Nodes

GPU workers use two layers:

1. Host support from `profiles/hardware/nvidia.nix`.
2. Kubernetes scheduling support from `modules/kubernetes/addons/nvidia-device-plugin.nix`.

## Host Layer

`profiles/hardware/nvidia.nix` enables:

- NVIDIA driver
- graphics support needed by the driver stack
- NVIDIA container toolkit
- `nvtop`

## Kubernetes Layer

The NVIDIA device plugin add-on is enabled in `inventory/kubernetes.nix`:

```nix
addons.nvidiaDevicePlugin = {
  enable = true;
  image = "nvcr.io/nvidia/k8s-device-plugin:v0.19.0";
};
```

The manifest targets nodes with:

```yaml
nodeSelector:
  homelab.local/gpu: nvidia
```

The current GPU worker profile sets that label and a matching taint.

## Checks

On the GPU node:

```sh
nvidia-smi
systemctl status k3s --no-pager
```

From the control plane:

```sh
sudo k3s kubectl get nodes --show-labels
sudo k3s kubectl -n kube-system get pods -l name=nvidia-device-plugin-ds -o wide
sudo k3s kubectl describe node gpu-worker-1 | grep -A5 nvidia.com/gpu
```

From the repo dev shell:

```sh
homelab status gpu-worker-1 k3s
homelab kubectl -n kube-system get pods -l name=nvidia-device-plugin-ds -o wide
```
