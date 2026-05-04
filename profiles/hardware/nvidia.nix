{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
