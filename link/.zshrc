if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

autoload -U promptinit; promptinit

if prompt -l | grep '\bpure\b' &> /dev/null; then
  prompt pure
else
  prompt redhat
fi


if [[ -d "$HOME/.volta" ]]; then
  PATH="$HOME/.volta/bin:$PATH"
else
  echo "Couldn't find volta. You may want to install."
fi

# Brew stuff (macOS-specific)
if type brew &> /dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  _dir="$(brew --prefix)/opt/coreutils"
  if [[ -d $_dir ]]; then
    PATH="$_dir/libexec/gnubin:$PATH"
    MANPATH="$_dir/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install coreutils`.'
  fi

  _dir="$(brew --prefix)/opt/grep"
  if [[ -d $_dir ]]; then
    PATH="$_dir/libexec/gnubin:$PATH"
    MANPATH="$_dir/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install grep`.'
  fi

  _dir="$(brew --prefix)/opt/gnu-sed"
  if [[ -d $_dir ]]; then
    PATH="$_dir/libexec/gnubin:$PATH"
    MANPATH="$_dir/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install gnu-sed`.'
  fi

  unset _dir
fi

# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete # _ignored _correct _approximate
zstyle :compinstall filename '/Users/jonsurrell/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


HISTFILE=~/.histfile
HISTSIZE=3000
SAVEHIST=3000
setopt \
    APPEND_HISTORY         \
    EXTENDED_GLOB          \
    HIST_EXPIRE_DUPS_FIRST \
    HIST_FIND_NO_DUPS      \
    HIST_IGNORE_DUPS       \
    HIST_IGNORE_SPACE      \
    NO_AUTO_CD             \
    SHARE_HISTORY

bindkey -v


#
# Key bindings
#

# Atuin - sqlite shell history https://atuin.sh/
if type atuin &> /dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r'   _atuin_search_widget      # ctrl-r
  bindkey '^[[A' _atuin_up_search_widget   # up arrow
  bindkey '^p'   _atuin_up_search_widget   # ctrl-p
fi

## DISABLE FOR ATUIN HISTORY
##
## # ctrl-p previous
## bindkey '^P' up-line-or-history
##
## # ctrl-n next
## bindkey '^N' down-line-or-history
##
## # ctrl-r history search
## bindkey '^R' history-incremental-pattern-search-backward
## /DISABLE FOR ATUIN

# ctrl-w delete word back
bindkey '^W' backward-kill-word

export KEYTIMEOUT=1

alias "cd.."='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

if [[ "$(ls --version | head -n1)" =~ '^ls \(GNU coreutils\) 9\.' ]]; then
  alias ls="ls --classify=auto --color=auto --group-directories-first --hyperlink=auto"
else
  alias ls="ls --classify --color=auto --group-directories-first"
fi

if hash kitty 2>/dev/null; then
  alias rg='kitty +kitten hyperlinked_grep'
fi

# Subversion
alias svn-remove-missing='svn rm $(svn st | grep "^!" | cut -c 9-)'

#
# Git
# #
# Branch cleanup
alias git-clean-branches='git fetch -p && git branch -l --format="%(if)%(worktreepath)%(then)%(worktreepath) %(upstream:track)%(end)" | awk '"'"'/\[gone\]/ { print $1 }'"'"' | xargs -n 1 git worktree remove --force ; git branch -l --format="%(refname:short) %(upstream:track)" |  awk '"'"'/\[gone\]/ {print $1 }'"'"' | xargs git branch -D'

# Open current PR in browser
alias ghw='gh pr view --web'
# Print the current PR URL - handy to share, e.g. `ghu | pbcopy`
alias ghu='gh pr view --json url --jq .url'
# Create a new PR for the current branch
alias ghpr='gh pr create'

alias fixdns="networksetup -listallnetworkservices | tail -n +2 | xargs -I{} sh -c "'"'"printf 'Setting DNS for service: {}'; networksetup -setdnsservers '{}' 9.9.9.9 149.112.112.112 2620:fe::fe 2620:fe::9 && echo ' ✅ OK!' || echo ' ⛔️ Non-zero exit!'"'"; sudo -p "Authorize to flush dns caches" sh -c "dscacheutil -flushcache; killall -HUP mDNSResponder"; sudo -K'
alias checkdns="networksetup -listallnetworkservices | tail -n +2 | xargs -I{} sh -c "'"'"echo 'DNS servers for {}:'; networksetup -getdnsservers '{}'; echo"'"'

alias darkmode='osascript -e '"'"'tell app "System Events" to tell appearance preferences to set dark mode to true'"'"'; kitty +kitten themes --reload-in=all "Tokyo Night Storm"; [[ -n $TMUX ]] && tmux source  ~/.local/share/nvim/site/pack/packer/start/tokyonight.nvim/extras/tmux/tokyonight_storm.tmux; pgrep nvim >/dev/null && (setopt NO_NOTIFY NO_MONITOR; lsof -p $(pgrep nvim | tr "\n" ",") | awk '"'"'$5 == "unix" && $8 ~ /nvim/ { print $8 } '"'"' | python -c '"'"'import sys
import neovim as n
servers = sys.stdin.read().splitlines()
def set_theme(s):
  nvim = n.attach("socket", path=s)
  nvim.command("set background='"'"'dark'"'"'")
  nvim.command("colorscheme tokyonight-storm")
  nvim.close()
list(map(set_theme, servers))'"'"') &|'

alias lightmode='osascript -e '"'"'tell app "System Events" to tell appearance preferences to set dark mode to false'"'"'; kitty +kitten themes --reload-in=all "Everforest Light Medium"; [[ -n $TMUX ]] && tmux source  ~/.local/share/nvim/site/pack/packer/start/tokyonight.nvim/extras/tmux/tokyonight_day.tmux; pgrep nvim >/dev/null && (setopt NO_NOTIFY NO_MONITOR; lsof -p $(pgrep nvim | tr "\n" ",") | awk '"'"'$5 == "unix" && $8 ~ /nvim/ { print $8 } '"'"' | python -c '"'"'import sys
import neovim as n
servers = sys.stdin.read().splitlines()
def set_theme(s):
  nvim = n.attach("socket", path=s)
  nvim.command("set background='"'"'light'"'"'")
  nvim.command("colorscheme everforest")
  nvim.close()
list(map(set_theme, servers))'"'"') &|'



# Set UTF-8 and English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Fix for GPG signing (git signed commits) "Inappropriate ioctl for device"
export GPG_TTY=$(tty)

# Set shell editors
if hash nvim 2>/dev/null; then
  export _VIM=nvim
else
  echo 'You may want to `brew install neovim`.'
  export _VIM=vim
fi

# Visual editor vim: noswap, nocompat, norc/plugins
export EDITOR="$_VIM --clean"
export VISUAL="$EDITOR"

# Git editor
export GIT_EDITOR="$_VIM -n -u NONE -i NONE -S $HOME/.dotfiles/config/gitcommit.nvimrc"

# SVN editor
export SVN_EDITOR="$VISUAL"

unset _VIM

# Node / npm / yarn stuff
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export CHROMEDRIVER_SKIP_DOWNLOAD=true
export PUPPETEER_SKIP_DOWNLOAD=true


# Source local shell config file
if [[ -f ~/.zshrc.local ]]; then
  . ~/.zshrc.local
fi

# vi et sw=4 ts=4 sts=4
