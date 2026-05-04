{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "en* eth*";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
    };
  };

  services.resolved.enable = true;
}
