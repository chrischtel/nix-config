# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    # ./zsh.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "chrischtel";
    homeDirectory = "/home/chrischtel/";
  };

  # Add stuff for your user as you see fit:
  programs.neovim.enable = true;

  # home.packages = with pkgs; [ chrome ];
    home.packages = with pkgs; [
      pinentry-gtk2  # Or pinentry-qt or pinentry-curses
      gnupg
  ];

  # Configure GPG agent
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    maxCacheTtl = 7200;
    enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2;  # Or pkgs.pinentry-qt or pkgs.pinentry-curses
  };

  programs.alacritty = {
    enable = true;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "ch@brendlinonline.de";
    userName = "Christian Brendlin";

    delta = {
        enable = true;
    };
    
    signing = {
      key = "2EF22D6304BD59B1";
      signByDefault = true;
    };

        extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      gpg.program = "${pkgs.gnupg}/bin/gpg2";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };

    aliases = {
      s = "status -s";
      st = "status";
      cl = "clone";
      ci = "commit";
      co = "checkout";
      br = "branch";
      dc = "diff --cached";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
