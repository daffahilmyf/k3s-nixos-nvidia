{ username, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.${username} = import ../../home/users/daffa.nix;
  };
}
