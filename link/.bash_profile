# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Source all the files in bash_source
# @todo Make this work with directory scheme
for file in ~/.dotfiles/source/*; do
    if [[ -d $file ]]; then
        if [[ $(uname -s) == $(basename "$file") ]]; then
            for file2 in "$file"/*; do
                source "$file2"
            done
        fi
        continue
    fi
    source "$file"
done
unset file

# Source ~/.bash_private
[[ -f ~/.bash_private ]] && source ~/.bash_private

if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# homebrew bash completion
export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && ! shopt -oq posix; then
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

export PATH="$HOME/.cargo/bin:$PATH"

# vi et sw=4 ts=4 sts=4
