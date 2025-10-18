# --------------------------------------------------------
# 1. Plugin Management (using Fisher)
# --------------------------------------------------------
# Check if Fisher is installed. If not, install it.
if not functions -q fisher
    echo "Installing fisher..."
    curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    fish -c fisher
end

# Install plugins using Fisher. These are defined in a file.
# Fisher will automatically read and install plugins listed in `~/.config/fish/fish_plugins`.
# The `fish_plugins` file simply contains a list of plugin names, one per line.

# --------------------------------------------------------
# 2. Environment Variables
# --------------------------------------------------------
# Set the default text editor for the shell and graphical applications.
# The `-x` flag makes the variable immediately exported.
set -x EDITOR "nvim"
set -x VISUAL "nvim"

# Disable the fish greeting message to have a clean startup.
# set -g fish_greeting ""

# Use a universal variable for fish_key_bindings.
# Universal variables persist across shell sessions.
# This example uses Vi-mode bindings.
set -U fish_key_bindings fish_vi_key_bindings

# Add custom paths to the PATH variable.
# fish_add_path is a built-in helper that avoids duplicates.
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.npm-global/bin"
fish_add_path "$HOME/.cargo/bin"

# --------------------------------------------------------
# 3. Aliases and Abbreviations
# --------------------------------------------------------
# Use `abbr` for expansions rather than the `alias` command.
# Abbreviations expand on the command line as you type.
# The `-a` flag adds the abbreviation, and `-g` makes it global.
abbr -a -g g git
abbr -a -g gs git status
abbr -a -g ga git add
abbr -a -g gc git commit -m
abbr -a -g gp git push
abbr -a -g v $EDITOR # 'v' for vim

# Use the `alias` command for more complex or traditional aliases.
# Check if `exa` (a modern `ls` alternative) exists before creating aliases.
if command -q exa
    alias la="exa -abghl --git --color=automatic"
    alias ll="exa -bghl --git --color=automatic"
else
    # Fallback to standard ls if exa isn't available
    alias la="ls -alh"
    alias ll="ls -lh"
end

# --------------------------------------------------------
# 4. Custom Functions
# --------------------------------------------------------
# A simple function to create and navigate to a new directory.
function mkcd
    mkdir $argv
    cd $argv
end

# A function to run a command without adding it to the history.
function h
    history -p (history | head -n1)
end

# Example of a custom prompt function.
# This function would be saved in ~/.config/fish/functions/fish_prompt.fish
# You can also use a tool like Starship for more advanced prompts.
function fish_prompt
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' > '
end

# --------------------------------------------------------
# 5. Conditional Settings
# --------------------------------------------------------
# Apply settings only for interactive shells.
# `status is-interactive` checks if the shell is interactive.
if status is-interactive
    # Set the history to save a large number of entries.
    set -U fish_history_max_entries 10000
end

# Apply settings only for login shells.
# For example, to run an update check.
if status is-login
    # Example: Run a software update checker like `brew update`
    # command -q brew; and brew update
end

# ~/.config/fish/config.fish

# Suppress fish greeting
set -g fish_greeting

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# Path additions (add your custom paths here)
# fish_add_path ~/.local/bin
# fish_add_path ~/.cargo/bin

# ============================================
# Tool Configurations
# ============================================

# Starship prompt (must be at end of config)
if type -q starship
    starship init fish | source
end

# fzf configuration
if type -q fzf
    # Use fd if available, otherwise fall back to find
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end
    
    # fzf color scheme (adjust to your preference)
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --margin=1 --padding=1'
    
    # fzf key bindings
    fzf --fish | source
end

# bat configuration
if type -q bat
    set -gx BAT_THEME "Catppuccin Mocha"
    set -gx BAT_STYLE "numbers,changes,header"
end

# ============================================
# Aliases
# ============================================

# exa (ls replacement)
if type -q exa
    alias ls='exa --icons --group-directories-first'
    alias la='exa --icons --group-directories-first -a'
    alias ll='exa --icons --group-directories-first -l --git'
    alias lla='exa --icons --group-directories-first -la --git'
    alias lt='exa --icons --group-directories-first --tree --level=2'
    alias lta='exa --icons --group-directories-first --tree --level=2 -a'
end

# bat (cat replacement)
if type -q bat
    alias cat='bat --paging=never'
    alias catp='bat' # with paging
end

# ripgrep
if type -q rg
    alias grep='rg'
end

# Common shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias reload='source ~/.config/fish/config.fish'

# System info
if type -q neofetch
    alias nf='neofetch'
end

# ============================================
# Functions
# ============================================

# Quick directory navigation with fzf
function fcd
    set -l dir (fd --type d --hidden --follow --exclude .git | fzf --prompt="Directory: " --preview='exa --tree --level=1 --icons {}')
    and cd $dir
end

# Search and edit file with fzf and ripgrep
function fe
    set -l file (rg --files --hidden --follow --glob '!.git' | fzf --prompt="Edit: " --preview='bat --color=always --style=numbers --line-range=:500 {}')
    and $EDITOR $file
end

# Interactive ripgrep with fzf
function rgf
    rg --color=always --line-number --no-heading --smart-case "$argv" |
        fzf --ansi --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window '+{2}/2' \
            --bind 'enter:execute($EDITOR +{2} {1})'
end

# Better history search
function fh
    history | fzf --tac --no-sort | read -l cmd
    and commandline -r $cmd
end

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Extract archives
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# ============================================
# Startup
# ============================================

# Show neofetch on new terminal (comment out if you don't want this)
if status is-interactive
    and type -q neofetch
    neofetch
end
