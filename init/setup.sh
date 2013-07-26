#!/bin/bash

# Determine current system
case $(uname) in
    "Linux")
        echo "You're on a Linux system!"
        THIS_SYSTEM=linux
        ;;
    "Darwin")
        echo "You're on a Mac!"
        THIS_SYSTEM=mac
        ;;
    *)
        echo "I'm not sure what system you're on :(" >&2
        exit 1
        ;;
esac

bootstrap() {
    touch ~/.hushlogin # silence login
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

# Test whether a command exists
# $1 - cmd to test
type_exists() {
    if [ `type -P $1` ]; then
      return 0
    fi
    return 1
}

run_apt() {
    # sudo add-apt-repository http://dl.google.com/linux/talkplugin/deb/
    # sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install -y $(<apt_packages)
}

run_brew() {
    if [[ $THIS_SYSTEM != 'mac' ]]; then
        echo "Homebrew is only for mac." >&2
        return
    fi
    if ! type_exists 'brew'; then
        echo "Homebrew not installed or not found."
        read -e -p "Install? (y/N): " HB
        HB=${HB:-"NO"}
        case $inst in
            "y"|"Y"|"yes")
                ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
                ;;
            *)
                return
                ;;
        esac
    fi
    if [ ! -f brew_formula ]; then
        echo "brew_formula file not found. Aborting formula install." >&2
        return
    fi

    brew update
    brew install $(<brew_formula)

}

# npm package installation
run_npm() {
    # Check for npm
    if ! type_exists 'npm'; then
        echo "npm not installed or not found. Aborting Node.js module install." >&2
        return
    fi

    if [ ! -f global_node_modules ]; then
        echo "global_node_modules file not found. Aborting Node.js module install." >&2
        return
    fi

    echo "Updating npm..."
    npm update -g -q npm
    echo "npm updated."

    case $THIS_SYSTEM in
        "mac")
            if [ -d $(brew --prefix)/etc/bash_completion.d ]; then
                npm completion > $(brew --prefix)/etc/bash_completion.d/npm
            fi
            ;;
        "linux")
            if [ -d /etc/bash_completion.d ]; then
                npm completion > /etc/bash_completion.d/npm
            fi
            ;;
    esac

    # Install packages globally and quietly
    echo "Installing Node.js modules..."
    sudo npm install --global --quiet $(<global_node_modules)
    echo "Node.js modules installed!"
}

# The variable $0 is the script's name. The total number of arguments is stored in $#. The variables $@ and $* return all the arguments.
if [[ $# -eq 0 ]]; then
    echo "Full dotfile bootstrap..."
elif [[ $# -gt 0 ]]; then
    for var in "$@"; do
        case "$var" in
            "bootstrap")
                echo "Full system bootstrap. This will symlink files to ~ (possibly overwriting)."
                read -e -p "Continue? (y/N): " BS
                BS=${BS:-"NO"}
                case $BS in
                    "y"|"Y"|"yes")
                        # Do everything
                        echo "bootstrap..."
                        bootstrap
                        ;;
                    *)
                        exit 0
                        ;;
                esac
                ;;
            "packages" | "modules")
                echo "Install packages..."
                case $THIS_SYSTEM in
                    "mac")
                        ;;
                    "linux")
                        ;;
                esac
                ;;
            "node" | "npm")
                run_npm
                ;;
            "apt")
                run_apt
                ;;
            "brew"|"homebrew")
                run_brew
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
