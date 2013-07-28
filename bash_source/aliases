# Grep history
alias hig='history | grep'
# Don't save history for current session
alias nohistory='unset HISTFILE'

# Navigation
alias "cd.."='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

# customize ls
# Detect ls color flag
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag='--color=auto'
else # OS X `ls`
    colorflag='-G'
fi
alias ls="ls -F ${colorflag}"
alias l="ls -lAF ${colorflag}"
alias la="ls -aF ${colorflag}"
unset colorflag

# Enable aliases to be sudo’ed
alias sudo='sudo '

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done
