#!/bin/bash

# Determine current system
# Define helper functions base on system
case $(uname -s) in
    "Linux")
        echo "You're on a Linux system!"
        THIS_SYSTEM=linux
        ;;
    "Darwin")
        echo "You're on a Mac!"
        THIS_SYSTEM=osx
        ;;
    *)
        echo "I'm not sure what system you're on :(" >&2
        exit 1
        ;;
esac

# Read link target directive
# Allow different location depending on system
get_link_target() {
    case "$THIS_SYSTEM" in
        "linux")
            if [ -f "$1.linux_target" ]; then
                LINK_TARGET="$(<"$1.linux_target")"
                [ -z "$LINK_TARGET" ] && return 1
                # This crappy eval allows link expansion (~/...)
                #eval LINK_TARGET=$LINK_TARGET
                return
            fi
        ;;
        "osx")
            if [ -f "$1.osx_target" ]; then
                LINK_TARGET=$(printf "%q" "$(<"$1.osx_target")")
                [ -z $LINK_TARGET ] && return 1
                # This crappy eval allows link expansion (~/...)
                #eval LINK_TARGET=$LINK_TARGET

                echo "LINKING: $LINK_TARGET"

                return
            fi
        ;;
    esac
    [ -f "$1.target" ] && LINK_TARGET=$(<"$1.target") && return
    LINK_TARGET="$HOME/$1"
}

# TODO finish for osx
link_file() {
    local _flags
    case "$THIS_SYSTEM" in
        "linux")
            _flags='-sniv'
        ;;
        "osx")
            _flags='-shiv'
        ;;
    esac

    [ -d $(dirname $2) ] || mkdir -p $(dirname $2)
    ln $_flags "${1}" ${2}
}

bootstrap() {
    touch ~/.hushlogin # silence login

    local _dir _linkdir _file _line LINK_TARGET
    _dir=$(pwd)

    _linkdir="$HOME/.dotfiles/link/"
    cd "$_linkdir"
    for _file in $(ls -A $_linkdir); do

        # Don't link our link target directive files
        [[ $_file = ?*.*target ]] && continue

        # Sets a global variable LINK_TARGET
        # If link shouldn't be set for this OS (blank config file)
        # then we abort the linking
        get_link_target $_file || continue

        echo "LINK: ${_linkdir}${_file} -> $LINK_TARGET"

        # Link the file
        link_file "${_linkdir}${_file}" $LINK_TARGET
    done
    cd $_dir
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
    type -P "$1" > /dev/null || return 1 && return 0
}

#
confirm() {
    local _conf
    read -s -n 1 -p "Do you want to continue [y/N]? " _conf
    echo
    case $_conf in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

run_apt() {
    # sudo add-apt-repository http://dl.google.com/linux/talkplugin/deb/
    # sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install -y $(< ~/.dotfiles/setup/install/apt)
}

run_brew() {
    if [ "$THIS_SYSTEM" != 'osx' ]; then
        echo "Homebrew is only for mac." >&2
        return 1
    fi
    if ! type_exists 'brew'; then
        echo "Hombrew not found, will be installed."
        confirm || return && ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    fi
    if [ ! -r ~/.dotfiles/setup/install/homebrew ]; then
        echo "brew_formula file not found. Aborting formula install." >&2
        return
    fi

    brew update
    brew install $(< ~/.dotfiles/setup/install/homebrew)

}

# npm package installation
run_npm() {
    # Check for npm
    if ! type_exists 'npm'; then
        echo "npm not installed or not found. Aborting Node.js module install." >&2
        return 1
    fi

    if [ ! -r ~/.dotfiles/setup/install/node ]; then
        echo "global_node_modules file not found. Aborting Node.js module install." >&2
        return 1
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
    sudo npm install --global --quiet $(< ~/.dotfiles/setup/install/node)
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
                confirm || exit && bootstrap
                # read -s -n 1 -p "Do you want to continue [y/N]? " BS
                # echo
                # case $BS in
                #     y*|Y*)
                #         # Do everything
                #         bootstrap
                #         ;;
                #     *)
                #         exit 0
                #         ;;
                # esac
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
