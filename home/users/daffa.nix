{ pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -alh";
        rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home.packages = with pkgs; [
    bat
    eza
    fzf
    ncdu
    yq
  ];
}
