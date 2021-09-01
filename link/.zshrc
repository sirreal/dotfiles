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

# Powerline
# POWERLINE_COMMAND=$HOME/.local/bin/powerline-hs
# POWERLINE_CONFIG_COMMAND=true
# source "$HOME/jon/powerline-hs/powerline/powerline/bindings/zsh/powerline.zsh"

# History substring
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions
fpath=(/usr/local/share/zsh-completions $fpath)
if [ -f ~/.config/exercism/exercism_completion.zsh ]; then
  . ~/.config/exercism/exercism_completion.zsh
fi

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

alias git-clean-branches='git fetch -p && git branch -vv | grep '"'"'origin/.*: gone]'"'"' | awk '"'"'{print $1}'"'"' | xargs git branch -D'
alias gettestemail='echo "jon.surrell+$( openssl rand -hex 10 )@gmail.com" | pbcopy'


_paths=(
  /usr/local/bin \
  /usr/local/sbin \
  /usr/local/opt/ruby/bin \
  /usr/local/share/npm/bin \
  ~/go/bin \
  ~/.cabal/bin \
  ~/.composer/vendor/bin \
  ~/Library/Python/*/bin \
  ~/.cargo/bin \
  ~/.local/bin \
  ~/bin \
)

for _p in ${_paths[@]}; do
  if [[ -d $_p ]] && [[ ":$PATH:" != *":$_p:"* ]]; then
    export PATH="$_p:$PATH"
  fi
done
unset _p
unset _paths

# Set UTF-8 and English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

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

# NPM config settings
# Don't version .npmrc which may contain passwords
export npm_config_spin=false
export npm_config_progress=true

# OPAM configuration
. /Users/jonsurrell/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
