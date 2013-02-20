# Basic shell stuff
if [ $(uname) = 'Linux' ]; then
	alias 'ls'='ls --color=auto -F'
	alias 'l'='ls --color=auto -lAF'
	alias 'la'='ls --color=auto -aF'
	alias 'lsd'='ls --color=auto -lA | grep ^d'
    export GREP_OPTIONS='--color=auto --exclude-dir=.svn'
elif [ $(uname) = 'Darwin' ]; then
	alias 'ls'='ls -FG'
	alias 'l'='ls -lAFG'
	alias 'la'='ls -aFG'
	alias 'lsd'='ls -lAG | grep ^d'
    export GREP_OPTIONS='--color=auto'
fi

alias 'hig'='history | grep'
alias 'nohistory'='unset HISTFILE'

alias '~'='cd ~'
alias 'cd..'='cd ..'
alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
alias '.....'='cd ../../../..'
alias '......'='cd ../../../../..'
alias '.......'='cd ../../../../../..'

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
