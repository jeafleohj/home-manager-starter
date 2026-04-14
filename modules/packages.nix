{ pkgs, ... }:

{
  xdg.enable = true;

  home.packages = with pkgs; [
    awscli2
    bash
    fnm
    gh
    git
    gnumake
    gnupg
    jq
    just
    mkcert
    pnpm
    ripgrep
    ruff
    ssm-session-manager-plugin
    tree
    zellij
  ];

  xdg.configFile."just".source = ../dotfiles/just;
  xdg.configFile."nix".source = ../dotfiles/nix;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  home.sessionVariables.SHELL = "zsh";

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "fnm"
        "vi-mode"
      ];
      theme = "ys";
    };
  };

}
