{
  systemSettings,
  username,
  ...
}:

let
  userHome = ../../home/users + "/${username}.nix";
in

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit systemSettings username;
    };
    users.${username} = import userHome;
  };
}
