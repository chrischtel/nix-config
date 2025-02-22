# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
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

  home.file.".config/alacritty/alacritty.toml".text = ''
    [window]
    padding = { x = 4, y = 4 }
    decorations = "none"
    startup_mode = "Maximized"
    opacity = 0.98

    [scrolling]
    history = 10000
    multiplier = 3

    [font]
    normal = { family = "Iosevka Nerd Font Mono", style = "SemiBold" }
    bold = { family = "Iosevka Nerd Font Mono", style = "Bold" }
    italic = { family = "Iosevka Nerd Font Mono", style = "Italic" }
    bold_italic = { family = "Iosevka Nerd Font Mono", style = "Bold Italic" }
    size = 14.0
    offset = { x = 0, y = 1 }
    glyph_offset = { x = 0, y = 0 }

    [bell]
    animation = "EaseOutExpo"
    duration = 0
    color = "#ffffff"

    [selection]
    semantic_escape_chars = ",│`|:\"' ()[]{}<>\t"
    save_to_clipboard = true

    [cursor]
    style = { shape = "Block", blinking = "On" }
    blink_interval = 750
    unfocused_hollow = true
    thickness = 0.15

    [keyboard]
    bindings = [
      { key = "V", mods = "Command", action = "Paste" },
      { key = "C", mods = "Command", action = "Copy" },
      { key = "Key0", mods = "Command", action = "ResetFontSize" },
      { key = "Equals", mods = "Command", action = "IncreaseFontSize" },
      { key = "Minus", mods = "Command", action = "DecreaseFontSize" },
      { key = "K", mods = "Command", action = "ClearHistory" },
      { key = "V", mods = "Control|Shift", action = "Paste" },
      { key = "C", mods = "Control|Shift", action = "Copy" },
      { key = "N", mods = "Command", action = "SpawnNewInstance" },
      { key = "Q", mods = "Command", action = "Quit" },
      { key = "F", mods = "Command", action = "ToggleFullscreen" }
    ]

    [general]
    live_config_reload = true
    import = ["~/.config/alacritty/themes/gruvbox.toml"]

    [terminal]

    [terminal.shell]
    program = "/run/current-system/sw/bin/zsh"
    args = ["-l", "-c", "tmux attach || tmux"]
  '';

  # Add stuff for your user as you see fit:
  programs.neovim.enable = true;
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    # Set the base index for windows (and panes)
    baseIndex = 1;
    # Increase scrollback by setting history limit
    historyLimit = 50000;
    # Set tmux escape time (in ms)
    escapeTime = 10;
    # Pass focus events to tmux if supported by the terminal
    focusEvents = true;
    # Enable mouse support
    mouse = true;
    # Use vi-style key bindings in copy mode
    keyMode = "vi";

    prefix = "C-a";
    extraConfig = ''
                  # Plugin configurations
      set -g @resurrect-strategy-nvim 'session'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'

      ##############################
      # Improve colors
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      ##############################
      # Windows and pane numbering is handled by baseIndex,
      # but also renumber windows in case of changes.
      set -g renumber-windows on

      ##############################
      # Neovim specific settings (also reflected by escapeTime and focusEvents)
      set-option -sg escape-time 10
      set-option -g focus-events on

      ##############################
      # Vi mode and copy-mode bindings
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      ##############################
      # Split panes with the current path preserved
      bind '|' split-window -h -c "#{pane_current_path}"
      bind '-' split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      ##############################
      # Pane switching using Alt-arrow without prefgx
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      ##############################
      # Vim-style pane selection using hjkl keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      ##############################
      # Resize panes using PREFIX H, J, K, L
      bind H resize-pane -L 5
      bind J resize-pane -D 5
      bind K resize-pane -U 5
      bind L resize-pane -R 5

      ##############################
      # Easy configuration reload
      bind r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."

      ##############################
      # Status bar customization
      set -g status-position top
      set -g status-justify left
      set -g status-style 'bg=default fg=#ebdbb2'
      set -g status-left ""
      set -g status-right '#[fg=#ebdbb2,bg=default] %Y-%m-%d #[fg=#ebdbb2,bg=default] %H:%M '
      set -g status-right-length 50
      set -g status-left-length 20

      ##############################
      # Window status formatting
      setw -g window-status-current-style 'fg=#ebdbb2 bg=default bold'
      setw -g window-status-current-format ' #I#[fg=#ebdbb2]:#[fg=#ebdbb2]#W#[fg=#ebdbb2]#F '
      setw -g window-status-style 'fg=#ebdbb2 bg=default'
      setw -g window-status-format ' #I#[fg=#ebdbb2]:#[fg=#ebdbb2]#W#[fg=#ebdbb2]#F '

      ##############################
      # Smart pane switching based on Vim awareness
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

    '';
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank

      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }

    ];
  };

  # home.packages = with pkgs; [ chrome ];
  home.packages = with pkgs; [
    pinentry-gtk2 # Or pinentry-qt or pinentry-curses
    gnupg
    deno
    clang
    cmake
    # binutils
    valgrind
    lldb
    pkg-config

    # Lua
    lua51Packages.lua
    lua51Packages.luarocks
    # Go
    go

    # Zig
    zig
    xclip

    firefox
    antidote
    bat
    fd
    fzf
    ripgrep
    eza
    lazygit
  ];

  # Configure GPG agent
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    maxCacheTtl = 7200;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2; # Or pkgs.pinentry-qt or pkgs.pinentry-curses
  };

  programs.alacritty = {
    enable = true;
  };

  home.file.".ripgreprc".text = ''
    --max-columns=150
    --max-columns-preview

    --type-add
    web:*.{html,css,js}*

    --hidden

    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!vendor/*

    --colors=line:style:bold
    --colors=line:fg:yellow
    --colors=path:fg:green
    --colors=path:style:bold
    --colors=match:fg:black
    --colors=match:bg:yellow
    --colors=match:style:nobold

    --smart-case

    --follow

    --line-number
  '';

  programs.zsh = {
    enable = true;
    package = pkgs.zsh;

    # History settings (example)
    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      size = 5000;
      save = 5000;
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
      saveNoDups = true;
    };

    # Commands to insert at the very top of .zshrc.
    initExtraFirst = ''
      # Set ZDOTDIR to use a custom configuration directory.
      export ZDOTDIR=$HOME/.config/zsh
    '';

    # Commands inserted before compinit is run.
    initExtraBeforeCompInit = ''
      # Basic history and shell options.
      HISTFILE=$HOME/.zsh_history
      HISTSIZE=5000
      SAVEHIST=5000
      setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups \
             hist_save_no_dups hist_ignore_dups hist_find_no_dups AUTO_CD AUTO_PUSHD \
             PUSHD_IGNORE_DUPS PUSHD_MINUS

      # A few aliases and environment variables.
      alias ls="eza --icons --git --group-directories-first"
      alias ll="eza -l --icons --git --group-directories-first"
      alias la="eza -la --icons --git --group-directories-first"
      alias tree="eza --tree --icons --group-directories-first"
      alias find="fd"
      alias grep="rg"
      alias top="btop"
      alias cd="z"

      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="less"
    '';

    # Commands appended at the end of your .zshrc.
    initExtra = ''
      ##############################
      # Initialize Starship prompt
      ##############################
      eval "$(starship init zsh)"

      ##############################
      # Additional Environment Settings & Aliases
      ##############################
      export BAT_THEME="gruvbox-dark"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      alias cat="bat --style=plain"
      alias less="bat --style=plain --paging=always"
      alias preview="bat --style=numbers,changes"

      export FLYCTL_INSTALL="$HOME/.fly"
      export PATH="$FLYCTL_INSTALL/bin:$PATH"

      ##############################
      # fzf configuration
      ##############################
      export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --border \
        --preview 'bat --color=always --style=numbers {}' --preview-window=right:60%"
      export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

      ##############################
      # Custom Functions
      ##############################
      function rgf() {
        RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
        # Use $$ to ensure a literal $ is output.
        INITIAL_QUERY="$${*:-}"
        FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
          fzf --bind "change:reload:$RG_PREFIX {q} || true" \
              --ansi --phony --query "$INITIAL_QUERY" \
              --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
              --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
      }

      ##############################
      # Antidote plugin manager setup (replacing zinit)
      ##############################
      # Antidote should already be enabled by Home Manager from the overall configuration.
      # If additional antidote commands are necessary, add them here.
    '';

    # Configure Antidote as the plugin manager.
    antidote = {
      enable = true;
      package = pkgs.antidote;
      useFriendlyNames = true;
      plugins = [
        "zdharma-continuum/fast-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
        "Aloxaf/fzf-tab"
      ];
    };
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

  programs.zoxide.enable = true;
  programs.starship.enable = true;
  programs.atuin.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
