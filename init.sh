if [ $(uname) = 'Linux' ]; then
    # Debian setup
    echo "You're on a Linux system!"
elif [ $(uname) = 'Darwin' ]; then
    # Mac setup
    echo "You're on a Mac!"
else
    echo "I'm not sure what system you're on :("
fi
