# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# eval "$(starship init bash)"

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
if type brew &> /dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
            [[ -r "$COMPLETION" ]] && source "$COMPLETION"
        done
        unset COMPLETION
    fi
    unset HOMEBREW_PREFIX
fi

# user completions
for COMPLETION in "${HOME}/.bash_completion/"*; do
    [[ -r "$COMPLETION" ]] && source "$COMPLETION"
done
unset COMPLETION


# vi et sw=4 ts=4 sts=4
