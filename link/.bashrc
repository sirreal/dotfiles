[ -n "$PS1" ] && source ~/.bash_profile

# added by travis gem
[ -f /Users/jonsurrell/.travis/travis.sh ] && source /Users/jonsurrell/.travis/travis.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
