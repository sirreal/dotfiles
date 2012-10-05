# Basic shell stuff
if [ $(uname) = 'Linux' ]; then
	alias 'ls'='ls --color=auto -F'
	alias 'l'='ls --color=auto -lAF'
	alias 'la'='ls --color=auto -aF'
elif [ $(uname) = 'Darwin' ]; then
	alias 'ls'='ls -FG'
	alias 'l'='ls -lAFG'
	alias 'la'='ls -aFG'
fi

alias '~'='cd ~'

alias 'cd..'='cd ..'

alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
alias '.....'='cd ../../../..'
alias '......'='cd ../../../../..'
alias '.......'='cd ../../../../../..'

if [ ! -x wget ]; then
	alias 'wget'='curl -OL'
fi
