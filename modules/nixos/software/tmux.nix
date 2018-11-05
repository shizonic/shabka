{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.mine.tmux;

  plugins = with pkgs; [
    tmuxPlugins.logging
    tmuxPlugins.prefix-highlight
    tmuxPlugins.fzf-tmux-url
  ];

  # TODO(high): Each color theme is defining it's own status format. The format
  # should be unified and nix should interpolate to set the correct format

  defaultTheme = gruvBox256Color;

  # TODO(high): Move this over to the theme once TMux module is merged upstream
  # in home-manager and this nixos module has been moved to the home module.
  # See https://github.com/rycee/home-manager/pull/388.
  seoul256Color = ''
    set-option -g status-justify left
    set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #{prefix_highlight} #[bg=colour235]#[fg=colour185] #h #[bg=colour236] '
    set-option -g status-left-length 16
    set-option -g status-bg colour237
    set-option -g status-right '#[bg=colour236] #[bg=colour237]#[fg=colour185] #{battery_icon} #{battery_percentage} #{battery_remain} #[bg=colour235] #(date "+%a %b %d %H:%M") #[bg=colour236] #[bg=colour237] #[bg=colour72] '
    set-option -g status-interval 60

    set-option -g pane-active-border-fg colour215
    set-option -g pane-border-fg colour185

    set-window-option -g window-status-format '#[bg=colour238]#[fg=colour107] #I #[bg=colour239]#[fg=colour110] #[bg=colour240]#W#[bg=colour239]#[fg=colour195]#F#[bg=colour238] '
    set-window-option -g window-status-current-format '#[bg=colour236]#[fg=colour215] #I #[bg=colour235]#[fg=colour167] #[bg=colour234]#W#[bg=colour235]#[fg=colour195]#F#[bg=colour236] '
  '';

  gruvBox256Color = ''
    # default statusbar colors
    set-option -g status-bg colour237 #bg1
    set-option -g status-fg colour223 #fg1

    # default window title colors
    set-window-option -g window-status-bg colour214 #yellow
    set-window-option -g window-status-fg colour237 #bg1

    set-window-option -g window-status-activity-bg colour237 #bg1
    set-window-option -g window-status-activity-fg colour248 #fg3

    # active window title colors
    set-window-option -g window-status-current-bg default
    set-window-option -g window-status-current-fg colour237 #bg1

    # pane border
    set-option -g pane-active-border-fg colour250 #fg2
    set-option -g pane-border-fg colour237 #bg1

    # message infos
    set-option -g message-bg colour239 #bg2
    set-option -g message-fg colour223 #fg1

    # writting commands inactive
    set-option -g message-command-bg colour239 #fg3
    set-option -g message-command-fg colour223 #bg1

    # pane number display
    set-option -g display-panes-active-colour colour250 #fg2
    set-option -g display-panes-colour colour237 #bg1

    # clock
    set-window-option -g clock-mode-colour colour109 #blue

    # bell
    set-window-option -g window-status-bell-style fg=colour235,bg=colour167 #bg, red

    ## Theme settings mixed with colors (unfortunately, but there is no cleaner way)
    set-option -g status-attr "none"
    set-option -g status-justify "left"
    set-option -g status-left-attr "none"
    set-option -g status-left-length "80"
    set-option -g status-right-attr "none"
    set-option -g status-right-length "80"
    set-window-option -g window-status-activity-attr "none"
    set-window-option -g window-status-attr "none"
    set-window-option -g window-status-separator ""

    set-option -g status-left "#[fg=colour248, bg=colour241] #S #[fg=colour241, bg=colour237, nobold, noitalics, nounderscore]"
    set-option -g status-right "#[fg=colour239, bg=colour237, nobold, nounderscore, noitalics]#[fg=colour246,bg=colour239] %Y-%m-%d  %H:%M #[fg=colour248, bg=colour239, nobold, noitalics, nounderscore]#[fg=colour237, bg=colour248] #h "

    set-window-option -g window-status-current-format "#[fg=colour239, bg=colour248, :nobold, noitalics, nounderscore]#[fg=colour239, bg=colour214] #I #[fg=colour239, bg=colour214, bold] #W #[fg=colour214, bg=colour237, nobold, noitalics, nounderscore]"
    set-window-option -g window-status-format "#[fg=colour237,bg=colour239,noitalics]#[fg=colour223,bg=colour239] #I #[fg=colour223, bg=colour239] #W #[fg=colour239, bg=colour237, noitalics]"
  '';


  tmuxVimAwarness = ''
    # Smart pane switching with awareness of Vim splits.
    # See: https://github.com/christoomey/vim-tmux-navigator
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
    bind-key -n M-n if-shell "$is_vim" "send-keys M-n"  "select-pane -L"
    bind-key -n M-e if-shell "$is_vim" "send-keys M-e"  "select-pane -D"
    bind-key -n M-i if-shell "$is_vim" "send-keys M-i"  "select-pane -U"
    bind-key -n M-o if-shell "$is_vim" "send-keys M-o"  "select-pane -R"
  '';

  colemakBindings = ''
    #
    # Colemak binding
    #

    # cursor movement
    bind-key -r -T copy-mode-vi n send -X cursor-left
    bind-key -r -T copy-mode-vi e send -X cursor-down
    bind-key -r -T copy-mode-vi i send -X cursor-up
    bind-key -r -T copy-mode-vi o send -X cursor-right

    # word movement
    bind-key -r -T copy-mode-vi u send -X next-word-end
    bind-key -r -T copy-mode-vi U send -X next-space-end
    bind-key -r -T copy-mode-vi y send -X next-word
    bind-key -r -T copy-mode-vi Y send -X next-space
    bind-key -r -T copy-mode-vi l send -X previous-word
    bind-key -r -T copy-mode-vi L send -X previous-space

    # search
    bind-key -r -T copy-mode-vi k send -X search-again
    bind-key -r -T copy-mode-vi K send -X search-reverse

    # visual mode
    bind-key -r -T copy-mode-vi a send -X begin-selection

    # yank
    bind-key -r -T copy-mode-vi c send -X copy-selection-and-cancel
    bind-key -r -T copy-mode-vi C send -X copy-selection

    # char search
    bind-key -r -T copy-mode-vi p command-prompt -1 -p "jump to forward" "send -X jump-to-forward \"%%%\""
    bind-key -r -T copy-mode-vi P command-prompt -1 -p "jump to backward" "send -X jump-to-backward \"%%%\""

    # resize panes
    bind-key M-n resize-pane -L 5
    bind-key M-e resize-pane -D 5
    bind-key M-i resize-pane -U 5
    bind-key M-o resize-pane -R 5

    # Change window move behavior
    bind . command-prompt "swap-window -t '%%'"
    bind > command-prompt "move-window -t '%%'"

    # More straight forward key bindings for splitting
    unbind %
    bind h split-window -h
    unbind '"'
    bind v split-window -v

    # The shortcut is set to <t> which overrides the default mapping for clock mode
    bind T clock-mode
  '';

  copyPaste =
    if pkgs.stdenv.isLinux then ''
      # copy/paste to system clipboard
      bind-key C-p run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --no-private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as public gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
      bind-key C-g run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as private gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
      bind-key C-c run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.xsel}/bin/xsel --clipboard -i"
      bind-key C-v run "${pkgs.xsel}/bin/xsel --clipboard -o | ${pkgs.tmux}/bin/tmux load-buffer; ${pkgs.tmux}/bin/tmux paste-buffer"
    '' else if pkgs.stdenv.isDarwin then ''
      # on OSX, set the default command to reattach-to-user-namespace
      # TODO: must install reattach-to-user-namespace through Nix to enable this!
      # set-option -g default-command "reattach-to-user-namespace -l zsh"
    '' else "";

in {

  options.mine.tmux.enable = mkEnableOption "Tmux";

  config = mkIf cfg.enable {
    programs.tmux = {
      # Rather than constraining window size to the maximum size of any client
      # connected to the *session*, constrain window size to the maximum size of any
      # client connected to *that window*. Much more reasonable.
      aggressiveResize = true;

      # Display the clock in 24 hours format
      clock24 = true;

      customPaneNavigationAndResize = true;
      enable = true;
      escapeTime = 0; # no ESC wait time. http://superuser.com/a/252717
      historyLimit = 50000;
      keyMode = "vi";
      shortcut = "t";
      terminal = "tmux-256color";

      extraTmuxConf = ''
        ${defaultTheme}
        ${tmuxVimAwarness}

        #
        # Settings
        #

        # don't allow the terminal to rename windows
        set-window-option -g allow-rename off

        # show the current command in the border of the pane
        set -g pane-border-status "top"
        set -g pane-border-format "#P: #{pane_current_command}"

        # Terminal emulator window title
        set -g set-titles on
        set -g set-titles-string '#S:#I.#P #W'

        # Status Bar
        set-option -g status on

        # Notifying if other windows has activities
        #setw -g monitor-activity off
        set -g visual-activity on

        # Trigger the bell for any action
        set-option -g bell-action any
        set-option -g visual-bell off

        # reload config
        bind R source-file /etc/tmux.conf \; display-message "Config reloaded..."

        # No Mouse!
        set -g mouse off

        # Do not update the environment, keep everything from what it was started with
        set -g update-environment ""

        # fuzzy client selection
        bind s split-window -p 20 -v ${pkgs.nur.repos.kalbasit.swm}/bin/swm tmux switch-client --kill-pane

        # Last active window
        bind C-t last-window
        bind C-r switch-client -l
        # bind C-n next-window
        bind C-n switch-client -p
        bind C-o switch-client -n

        # online status settings
        set -g status-interval 5

        # add all the plugins
        ${concatStrings (map (x: "run-shell ${x.rtp}\n") plugins)}

        # tmux-battery settings
        set -g @batt_remain_short true

        ${copyPaste}
      '' + optionalString config.mine.useColemakKeyboardLayout colemakBindings;
    };
  };
}
