# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete # _ignored _correct _approximate
zstyle :compinstall filename '/Users/jonsurrell/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=3000
SAVEHIST=3000
setopt appendhistory extendedglob
unsetopt autocd
bindkey -v
# End of lines configured by zsh-newuser-install

# Git prompt
# source "$HOME/jon/zsh-git-prompt/zshrc.sh"
# ZSH_THEME_GIT_PROMPT_PREFIX=""
# ZSH_THEME_GIT_PROMPT_SUFFIX=""
# ZSH_THEME_GIT_PROMPT_SEPARATOR=" | "
# ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
# ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{●%G%}"
# ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖%G%}"
# ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{✚%G%}"
# ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
# ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
# ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
# ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"

# GIT_PROMPT_EXECUTABLE="haskell"
# PROMPT='%B%m%~%b %# '
# RPROMPT='$(git_super_status)'

# Powerline
POWERLINE_COMMAND=$HOME/.local/bin/powerline-hs
POWERLINE_CONFIG_COMMAND=true
source "$HOME/jon/powerline-hs/powerline/powerline/bindings/zsh/powerline.zsh"

# History substring
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions
fpath=(/usr/local/share/zsh-completions $fpath)

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

export NVM_DIR="$HOME/.nvm"

export KEYTIMEOUT=1

alias git-clean-branches='git fetch -p && git branch -vv | grep '"'"'origin/.*: gone]'"'"' | awk '"'"'{print $1}'"'"' | xargs git branch -D'


_paths=(
  "/usr/local/bin" \
  "/usr/local/sbin" \
  "/usr/local/opt/ruby/bin" \
  "/usr/local/share/npm/bin" \
  "$HOME/go/bin" \
  "$HOME/.rvm/bin" \
  "$HOME/android-sdk-linux/platform-tools" \
  "$HOME/android-sdk-linux/build-tools" \
  "$HOME/android-sdk-linux/tools" \
  "$HOME/.cabal/bin" \
  "$HOME/.composer/vendor/bin" \
  "$HOME/.local/bin" \
  "$HOME/.npm-globals/bin" \
  "$HOME/bin" \
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

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

# NPM config settings
# Don't version .npmrc which may contain passwords
export npm_config_spin=false
export npm_config_progress=true

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

