eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

_coreutils_dir="$(brew --prefix)/opt/coreutils"
if [[ -d $_coreutils_dir ]]; then
  PATH="$_coreutils_dir/libexec/gnubin:$PATH"
  MANPATH="$_coreutils_dir/libexec/gnuman:$MANPATH"
fi

if [[ -d "$HOME/.volta" ]]; then
  PATH="$HOME/.volta/bin:$PATH"
fi

# Completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete # _ignored _correct _approximate
zstyle :compinstall filename '/Users/jonsurrell/.zshrc'


autoload -Uz compinit
compinit
# End of lines added by compinstall
#
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

# ctrl-p previous
bindkey '^P' up-line-or-history

# ctrl-n next
bindkey '^N' down-line-or-history

# ctrl-r history search
bindkey '^R' history-incremental-pattern-search-backward

# ctrl-w delete word back
bindkey '^W' backward-kill-word

# Set neovim as editor
if hash nvim 2>/dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

# Visual editor vim: noswap, nocompat, norc/plugins
export VISUAL="$EDITOR -nN -u NONE"

# Git editor
export GIT_EDITOR="$EDITOR -nN -u $HOME/.dotfiles/config/gitcommit.nvimrc"

# SVN editor
export SVN_EDITOR="$VISUAL"

export npm_config_spin=false
export npm_config_progress=true

export KEYTIMEOUT=1

alias "cd.."='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

alias gettestemail='echo "jon.surrell+$( openssl rand -hex 10 )@gmail.com" | pbcopy'
alias ghw='gh pr view --web'
alias ghu='gh pr view --json url --jq .url'
alias ghpr='gh pr create'

alias ls="ls --classify=auto --color=auto --group-directories-first --hyperlink=auto"
alias rg='kitty +kitten hyperlinked_grep'

# Subversion
alias svn-remove-missing='svn rm $(svn st | grep "^!" | cut -c 9-)'

# Git
# Branch cleanup
alias git-clean-branches='git fetch -p && git branch -vv | grep '"'"'origin/.*: gone]'"'"' | awk '"'"'{print $1}'"'"' | xargs git branch -D'

alias ghw='gh pr view --web'
alias ghu='gh pr view --json url --jq .url'
alias ghpr='gh pr create'

unset _ls_command



# Set UTF-8 and English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Set shell editors
if hash nvim 2>/dev/null; then
    export _VIM=nvim
else
    export _VIM=vim
fi

# Visual editor vim: noswap, nocompat, norc/plugins
export EDITOR="$_VIM --clean"
export VISUAL="$EDITOR"

# Fix for GPG signing (git signed commits) "Inappropriate ioctl for device"
export GPG_TTY=$(tty)


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
[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local

# vi et sw=4 ts=4 sts=4
