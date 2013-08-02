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
    local _system_target _base_target
    _system_target="${1}.${THIS_SYSTEM}_target"

    if [[ -f $_system_target ]]; then
        LINK_TARGET="$(<"$_system_target")"
        [[ $LINK_TARGET ]] || return 1
        return
    fi

    _base_target="${1}.target"
    if [[ -f $_base_target ]]; then
        LINK_TARGET="$(<"$_base_target")"
        [[ $LINK_TARGET ]] || return 1
        return
    fi

    LINK_TARGET=~/$(basename "$1")
}

# TODO finish for osx
link_file() {
    local _flags _dirname
    case "$THIS_SYSTEM" in
        "linux")
            _flags='-sniv'
        ;;
        "osx")
            _flags='-shiv'
        ;;
    esac


    echo "Preparing to link \"$1\" to \"$2\"."
    echo "If path to $2 doesn't exist, will be created."
    confirm || return

    _dirname=$(dirname "$2")
    [[ -d $_dirname ]] || mkdir -p "$_dirname"
    ln $_flags "$1" "$2"
}

bootstrap() {
    echo "Full system bootstrap. This will symlink files to ~ (possibly overwriting)."
    confirm || return

    local _dir _file _line _dotglob LINK_DIR LINK_TARGET

    LINK_DIR=~/.dotfiles/link

    # Move to ~/ to allow relative *.target
    _dir=$(pwd)
    cd ~

    # Get our dotglob to restore later, then set it
    shopt -q dotglob && _dotglob=-s || _dotglob=-u
    shopt -s dotglob

    for _file in ${LINK_DIR}/*; do

        # Don't link our link target directive files
        [[ $_file =~ \.([a-zA-Z]+_)?target$ ]] && continue

        # Sets a global variable LINK_TARGET
        # If link shouldn't be set for this OS (blank config file)
        # then we abort the linking
        get_link_target $_file || continue

        # Link the file
        link_file "${_file}" "$LINK_TARGET"
    done

    # Restore our dotglob setting
    shopt $_dotglob dotglob

    # Return to where we were.
    cd "$_dir"
    return 0
}

# @TODO: As copy/pasted, check for validity and add Mac version
google_talk_plugin() {
    echo 'Downloading Google Talk Plugin...'
    # Download Debian file that matches system architecture
    if [[ $(uname -i) = 'i386' ]]; then
        wget https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb
    elif [[ $(uname -i) = 'x86_64' ]]; then
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
    type -P "$1" > /dev/null && return 0 || return 1
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
    if [[ $THIS_SYSTEM != 'osx' ]]; then
        echo "Homebrew is only for mac." >&2
        return 1
    fi
    if ! type_exists 'brew'; then
        echo "Hombrew not found, will be installed."
        confirm && ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" || return
    fi
    if [[ ! -e ~/.dotfiles/setup/install/homebrew ]]; then
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

    if [[ ! -f ~/.dotfiles/setup/install/node ]]; then
        echo "global_node_modules file not found. Aborting Node.js module install." >&2
        return 1
    fi

    echo "Updating npm..."
    npm update -g -q npm
    echo "npm updated."

    case $THIS_SYSTEM in
        "mac")
            if [[ -d $(brew --prefix)/etc/bash_completion.d ]]; then
                npm completion > $(brew --prefix)/etc/bash_completion.d/npm
            fi
            ;;
        "linux")
            if [[ -d /etc/bash_completion.d ]]; then
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
    bootstrap
elif [[ $# -gt 0 ]]; then
    for var in "$@"; do
        case "$var" in
            "bootstrap")
                bootstrap && exit 0
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
