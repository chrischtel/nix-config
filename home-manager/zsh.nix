{ config, pkgs, ... }:

{
  # Set ZSH as the default shell
  home.defaultShell = pkgs.zsh;

  programs.zsh = {
    enable = true;

    # Additional configuration such as aliases
    extraConfig = ''
      alias ll="ls -lah"
    '';
  };
}

