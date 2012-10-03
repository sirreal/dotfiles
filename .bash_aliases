# Basic shell stuff
if [ $(uname) = 'Linux' ]; then
	alias 'ls'='ls --color=auto -F'
	alias 'l'='ls --color=auto -lAF'
elif [ $(uname) = 'Darwin' ]; then
	alias 'ls'='ls -FG'
	alias 'l'='ls -lAFG'
fi

alias '~'='cd ~'

alias 'cd..'='cd ..'

alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
alias '.....'='cd ../../../..'
alias '......'='cd ../../../../..'
alias '.......'='cd ../../../../../..'