{
  config,
  pkgs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
    nvtopPackages.nvidia
  ];

  systemd.services.k3s.path = with pkgs; [
    nvidia-container-toolkit
  ];
}
