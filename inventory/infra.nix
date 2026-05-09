{
  backup = {
    enable = false;
    repository = "";
    passwordSecretName = "restic-password";
    paths = [
      "/etc/nixos"
      "/var/lib/libvirt"
    ];
    exclude = [
      "/var/lib/libvirt/images/*.qcow2"
    ];
  };

  observability = {
    enable = true;
    exporters.node.enable = true;
  };

  power = {
    enable = true;
    cpuGovernor = "schedutil";
  };

  recovery = {
    serialConsole.enable = true;
    rescueSsh.enable = false;
  };

  remoteAccess = {
    tailscale = {
      enable = false;
      authKeySecretName = "tailscale-auth-key";
      useRoutingFeatures = "client";
    };
  };

  storage = {
    enable = true;
    btrfs.enable = true;
    zfs.enable = false;
    scratch = {
      enable = true;
      paths = [
        "/srv"
        "/var/lib/libvirt/images"
      ];
    };
  };
}
