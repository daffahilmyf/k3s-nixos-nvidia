{
  hostname,
  lib,
  systemSettings,
  ...
}:

let
  sopsFile = ../../secrets + "/${hostname}.yaml";
in

{
  sops = {
    age = {
      keyFile = systemSettings.sopsAgeKeyFile;
      generateKey = true;
    };
  }
  // lib.optionalAttrs (builtins.pathExists sopsFile) {
    defaultSopsFile = sopsFile;
  };
}
