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

# GREP: colorize, ignore versioning dirs, ignore binary files
# Detect grep exclude type
if grep --exclude-dir > /dev/null 2>&1; then # GNU `ls`
    excludeflag='--exclude-dir'
else # OS X `ls`
    excludeflag='--exclude-dir'
fi
export GREP_OPTIONS='--color=auto ${excludeflag}=.svn ${excludeflag}=.git --binary-files=without-match'
unset excludeflag

# Replace wget with "curl -OL" when not installed (Mac)
type -P wget &> /dev/null
if [ $? -eq 1 ]; then
    type -P curl &> /dev/null
    if [ $? -ne 1 ]; then
        alias wget="curl -OL";
        echo "wget not available, setting wget=curl -OL"
    else
        echo "wget and curl not installed."
    fi
fi

# Enable aliases to be sudo’ed
alias sudo='sudo '

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done
