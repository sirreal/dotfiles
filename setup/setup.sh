#!/bin/bash

# Update submodules
git submodule update --init --recursive

# Determine current system
# Define helper functions base on system
case $(uname -s) in
    "Linux")
        THIS_SYSTEM=linux
        ;;
    "Darwin")
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
    local _system_target _base_target _directive
    _system_target="${1}.${THIS_SYSTEM}_target"

    if [[ -f $_system_target ]]; then
        _directive="$(<"$_system_target")"
        [[ $_directive ]] || return 1
        if [[ $_directive =~ ^/ ]]; then
            LINK_TARGET="$_directive"
        else
            LINK_TARGET=~/"$_directive"
        fi
        return
    fi

    _base_target="${1}.target"
    if [[ -f $_base_target ]]; then
        _directive="$(<"$_base_target")"
        [[ $_directive ]] || return 1
        if [[ $_directive =~ ^/ ]]; then
            LINK_TARGET="$_directive"
        else
            LINK_TARGET=~/"$_directive"
        fi
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

    if [[ $1 == $(readlink "$2") ]]; then
        echo "\`$(basename $1)\` already linked correctly."
        return 0
    fi

    echo "Preparing to link \"$1\" to \"$2\"."
    echo "If path to $2 doesn't exist, will be created."
    confirm || return

    _dirname=$(dirname "$2")
    [[ -d $_dirname ]] || mkdir -p "$_dirname"
    ln $_flags "$1" "$2"
}

do_linking() {
    local _dir _file _line _dotglob LINK_DIR LINK_TARGET

    # Do all of our linking
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
}

bootstrap() {
    echo "Full system bootstrap. This will symlink files to ~ (possibly overwriting)."
    confirm || return

    do_linking

    # Install
    [[ $THIS_SYSTEM == 'osx' ]] && run_brew
    [[ $THIS_SYSTEM == 'linux' ]] && run_apt

    run_npm
    run_gem

    # Load any new shell setup
    source ~/.bashrc

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
    echo "APT: Updating..."
    sudo apt-get update -qq
    echo "APT: Installing..."
    sudo apt-get install -qq -y $(< ~/.dotfiles/setup/install/apt)
    echo "APT: Finished"
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
        echo "install/homebrew file not found. Aborting formula install." >&2
        return
    fi

    echo "HOMEBREW: Updating formula and installing packages..."

    if [[ $(brew update) && $(brew install $(< ~/.dotfiles/setup/install/homebrew)) ]]; then
        echo "HOMEBREW: Setup OK!"
    else
        echo "HOMEBREW: Setup failed!" >&2
        return 1
    fi
}

# npm package installation
run_npm() {
    # Check for npm
    if ! type_exists 'npm'; then
        echo "npm not installed or not found. Aborting Node.js module install." >&2
        return 1
    fi

    if [[ ! -f ~/.dotfiles/setup/install/npm ]]; then
        echo "install/npm file not found. Aborting Node.js module install." >&2
        return 1
    fi

    local _cmd _tee

    case $THIS_SYSTEM in
        "linux")
            _cmd="sudo npm"
            _tee="sudo tee"
            ;;
    esac

    # Defaults
    _cmd=${_cmd:-npm}
    _tee=${_tee:-tee}

    echo "Updating npm..."
    $_cmd update -g npm
    echo "npm updated."

    echo "Updating npm completion..."
    case $THIS_SYSTEM in
        "osx")
            if [[ -d $(brew --prefix)/etc/bash_completion.d ]]; then
                npm completion | $_tee $(brew --prefix)/etc/bash_completion.d/npm > /dev/null
            fi
            ;;
        "linux")
            if [[ -d /etc/bash_completion.d ]]; then
                npm completion | $_tee /etc/bash_completion.d/npm > /dev/null
            fi
            ;;
    esac
    echo "Npm completion OK."


    # Install packages globally and quietly
    echo "Installing Node.js modules..."
    $_cmd install --global --quiet $(< ~/.dotfiles/setup/install/npm)
    echo "Node.js modules installed!"
}

# gem (ruby) package installation
run_gem() {
    # Check for npm
    if ! type_exists 'gem'; then
        echo "gem not installed or not found. Aborting gem install." >&2
        return 1
    fi


    if [[ ! -f ~/.dotfiles/setup/install/gem ]]; then
        echo "Gem file not found. Aborting Node.js module install." >&2
        return 1
    fi

    # local _cmd
    # echo "Updating npm..."
    # npm update -g -q npm
    # echo "npm updated."

    local _cmd

    case $THIS_SYSTEM in
        "linux")
            _cmd="sudo gem"
            ;;
    esac

    _cmd=${_cmd:-gem}

    # Install packages globally and quietly
    echo "Installing gems..."
    $_cmd install --quiet $(< ~/.dotfiles/setup/install/gem)
    echo "Gems installed!"
}

# The variable $0 is the script's name. The total number of arguments is stored in $#. The variables $@ and $* return all the arguments.
if [[ $# -eq 0 ]]; then
    bootstrap && exit 0
elif [[ $# -gt 0 ]]; then
    for var in "$@"; do
        case "$var" in
            "bootstrap")
                bootstrap && exit 0
                ;;
            "packages" | "modules")
                echo "Install packages..."
                case $THIS_SYSTEM in
                    "mac")
                        run_brew
                        ;;
                    "linux")
                        run_apt
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
                run_gem
                ;;
            "link")
                do_linking
                ;;
            *)
                echo "I didn't understand \"$var\" :("
                ;;
        esac
    done
fi
