#!/bin/bash

# Test whether a command exists
# $1 - cmd to test
type_exists() {
    if [ `type -P $1` ]; then
      return 0
    fi
    return 1
}

run_apt() {
    sudo add-apt-repository http://dl.google.com/linux/talkplugin/deb/
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install -y $(<apt_packages)
}

# @TODO: As copy/pasted, check for validity and add Mac version
google_talk_plugin() {
    echo 'Downloading Google Talk Plugin...'
    # Download Debian file that matches system architecture
    if [ $(uname -i) = 'i386' ]; then
        wget https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb
    elif [ $(uname -i) = 'x86_64' ]; then
        wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
    fi
    # Install the package
    echo 'Installing Google Talk Plugin...'
    echo 'Requires root privileges:'
    sudo dpkg -i google-talkplugin_current*.deb
    sudo apt-get install -fy
    # Cleanup and finish
    rm google-talkplugin_current*.deb
    cd
    echo 'Done.'
}

# npm package installation
run_npm() {
    # Check for npm
    if type_exists 'npm'; then
        if [ ! -f global_node_modules ]; then
            echo "global_node_modules file not found. Aborting Node.js module install."
        fi

        log_success "Installing Node.js modules..."


        # List of npm packages
        local packages
        packages=$(<global_node_modules)


        # Install packages globally and quietly
        sudo npm install $packages --global --quiet

        "Node.js modules installed!"
    else
        echo "npm not installed or not found. Aborting Node.js module install."
    fi
}


# The variable $0 is the script's name. The total number of arguments is stored in $#. The variables $@ and $* return all the arguments.
if [[ $# -eq 0 ]]; then
    echo "Full dotfile bootstrap..."
elif [[ $# -gt 0 ]]; then
    for var in "$@"; do
        case "$var" in
            "bootstrap")
                echo "All modules..."
                ;;
            "node" | "npm")
                echo "Just node"
                ;;
            "ruby" | "gem")
                echo "Just ruby"
                ;;
            *)
                echo "I didn't understand \"$var\" :("
                ;;
        esac
    done
fi
