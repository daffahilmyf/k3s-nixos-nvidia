{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
    openssh.authorizedKeys.keys = [ ];
  };
}
