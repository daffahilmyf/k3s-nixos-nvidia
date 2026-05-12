{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMdcZZ6RtHBQunug6JhxMNQzof73oKKh/8bi6SMRZ57 daffa@k3s-homelab"
    ];
  };
}
