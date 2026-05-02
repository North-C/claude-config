# Path
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins (zsh-syntax-highlighting MUST be last)
plugins=(
  git
  gitfast
  colored-man-pages
  command-not-found
  copypath
  dirhistory
  extract
  fzf
  history
  sudo
  z
  zsh-completions
  zsh-autosuggestions
  forgit
  zsh-syntax-highlighting
)

# Oh My Zsh source
source $ZSH/oh-my-zsh.sh

# Completion (after oh-my-zsh)
autoload -Uz compinit && compinit -u

# --- Autosuggestions ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c6c6c"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Right arrow accepts full suggestion; Ctrl+right accepts one word at a time
bindkey '^[[1;5C' forward-word

# --- Modern CLI tool integrations ---

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# starship prompt
eval "$(starship init zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# broot (interactive directory browser)
# 首次运行 broot 会提示安装 shell 集成，确认后 br 命令退出时自动 cd
if command -v broot &>/dev/null; then
  [ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br
fi

# --- Aliases ---

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Modern replacements (if installed via apt later)
if command -v batcat &>/dev/null; then
  alias cat='batcat --paging=never'
elif command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -l --icons --git'
  alias la='eza -la --icons --git'
  alias lt='eza -T --icons --level=2'
else
  alias ll='ls -alF'
  alias la='ls -A'
fi

if command -v fd &>/dev/null; then
  alias find='fd'
fi

if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# Git shortcuts
alias gs='git status'
alias gl='git log --oneline -15'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gcl='git clone'

# General
alias vim='nvim 2>/dev/null || vim'
alias c='clear'
alias h='history'
alias ports='ss -tulanp'
alias path='echo -e ${PATH//:/\\n}'

# --- History ---
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --- Key bindings ---
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
