# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
# shopt -s cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

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
    # homebrew bash completion
    if [[ -f /usr/local/etc/bash_completion ]]; then
        source /usr/local/etc/bash_completion
    fi
fi

# vi et sw=4 ts=4 sts=4
