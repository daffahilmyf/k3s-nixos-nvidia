{ kubernetesInventory, lib, ... }:

let
  cfg = kubernetesInventory.addons.nvidiaDevicePlugin or { };
  enabled = cfg.enable or false;
  image = cfg.image or "nvcr.io/nvidia/k8s-device-plugin:v0.19.0";
in

{
  options.homelab.kubernetes.addons.nvidiaDevicePlugin.enable =
    lib.mkEnableOption "NVIDIA Kubernetes device plugin addon";

  config = lib.mkIf enabled {
    homelab.kubernetes.addons.nvidiaDevicePlugin.enable = true;

    homelab.kubernetes.manifests.nvidia-device-plugin = ''
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        name: nvidia-device-plugin-daemonset
        namespace: kube-system
      spec:
        selector:
          matchLabels:
            name: nvidia-device-plugin-ds
        updateStrategy:
          type: RollingUpdate
        template:
          metadata:
            labels:
              name: nvidia-device-plugin-ds
          spec:
            priorityClassName: system-node-critical
            nodeSelector:
              homelab.local/gpu: nvidia
            tolerations:
              - key: CriticalAddonsOnly
                operator: Exists
              - key: homelab.local/gpu
                operator: Equal
                value: nvidia
                effect: NoSchedule
              - key: nvidia.com/gpu
                operator: Exists
                effect: NoSchedule
            containers:
              - name: nvidia-device-plugin-ctr
                image: ${image}
                imagePullPolicy: IfNotPresent
                args:
                  - --fail-on-init-error=false
                  - --device-discovery-strategy=nvml
                env:
                  - name: LD_LIBRARY_PATH
                    value: /run/opengl-driver/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
                securityContext:
                  privileged: true
                volumeMounts:
                  - name: device-plugin
                    mountPath: /var/lib/kubelet/device-plugins
                  - name: dev
                    mountPath: /dev
                  - name: opengl-driver
                    mountPath: /run/opengl-driver
                    readOnly: true
                  - name: opengl-driver
                    mountPath: /usr/local/nvidia
                    readOnly: true
            volumes:
              - name: device-plugin
                hostPath:
                  path: /var/lib/kubelet/device-plugins
              - name: dev
                hostPath:
                  path: /dev
              - name: opengl-driver
                hostPath:
                  path: /run/opengl-driver
                  type: Directory
    '';
  };
}
