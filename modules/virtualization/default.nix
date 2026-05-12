{
  lib,
  nodeInventory,
  pkgs,
  username,
  ...
}:

let
  cfg = nodeInventory.virtualization or { };
  guestAgent = cfg.guestAgent or { };
in

{
  config = lib.mkMerge [
    (lib.mkIf (guestAgent.enable or false) {
      services.qemuGuest.enable = true;
    })

    (lib.mkIf (cfg.enable or false) {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = false;

      users.users.${username}.extraGroups = [
        "kvm"
        "libvirtd"
      ];

      environment.systemPackages = with pkgs; [
        bridge-utils
        libguestfs
        pciutils
        qemu_kvm
        usbutils
        virtiofsd
      ];
    })
  ];
}
