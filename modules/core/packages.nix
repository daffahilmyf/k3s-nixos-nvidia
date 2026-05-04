{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    curl
    dig
    fd
    git
    htop
    jq
    lsof
    neovim
    pciutils
    ripgrep
    rsync
    sops
    tmux
    tree
    unzip
    wget
  ];
}
