# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Set UTF-8 and English
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# Set vi as editor
export EDITOR=vi

# Add home directory bin
if [ -d $HOME/bin ]; then
    export PATH="$HOME/bin:$PATH"
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [[ $TERM == xterm* ]] && [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[00;32m\]\u:\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# Alias definitions.
if [ -r ~/.dotfiles/bash_aliases ]; then
    source ~/.dotfiles/bash_aliases
fi

# Unversioned bash
if [ -r ~/.bash_private ]; then
    source ~/.bash_private
else
    echo "You may add unversioned bash setup in ~/.bash_private"
    touch ~/.bash_private
fi

# GREP: colorize, ignore versioning dirs, ignore binary files
# Detect grep exclude type
if grep --exclude-dir > /dev/null 2>&1; then # GNU `ls`
    excludeflag='--exclude-dir'
else # OS X `ls`
    excludeflag='--exclude'
fi
export GREP_OPTIONS="--color=auto ${excludeflag}=.svn ${excludeflag}=.git --binary-files=without-match"
unset excludeflag

if [ -r /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# homebrew bash completion
if [ -r /usr/local/etc/bash_completion ]; then
    source /usr/local/etc/bash_completion
fi
