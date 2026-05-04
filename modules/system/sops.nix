{
  hostname,
  lib,
  ...
}:

let
  sopsFile = ../../secrets + "/${hostname}.yaml";
in

{
  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  } // lib.optionalAttrs (builtins.pathExists sopsFile) {
    defaultSopsFile = sopsFile;
  };
}
