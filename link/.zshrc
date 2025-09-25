if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

autoload -U promptinit; promptinit

if prompt -l | grep '\bpure\b' &> /dev/null; then
  export PURE_GIT_PULL=0
  prompt pure
else
  prompt redhat
fi

if [[ -d "$HOME/.bin" ]]; then
  PATH="$HOME/.bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/.volta" ]]; then
  PATH="$HOME/.volta/bin:$PATH"
else
  echo "Couldn't find volta. You may want to install."
fi

if [[ -d "$HOME/.composer/vendor/bin" ]]; then
  PATH="$PATH:$HOME/.composer/vendor/bin"
fi

if [[ -d "$HOME/.docker/cli-plugins" ]]; then
  PATH="$PATH:$HOME/.docker/cli-plugins"
fi

# Brew stuff (macOS-specific)
if type brew &> /dev/null; then
  FPATH="$HOME/.local/share/zsh_completions":"$(brew --prefix)/share/zsh-completions":"$FPATH"

  alias brewup='brew update --quiet && brew outdated && brew upgrade --quiet --greedy && brew upgrade --quiet --cask'

  _target="$(brew --prefix)/opt/coreutils"
  if [[ -d $_target ]]; then
    PATH="$_target/libexec/gnubin:$PATH"
    MANPATH="$_target/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install coreutils`.'
  fi

  _target="$(brew --prefix)/opt/grep"
  if [[ -d $_target ]]; then
    PATH="$_target/libexec/gnubin:$PATH"
    MANPATH="$_target/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install grep`.'
  fi

  _target="$(brew --prefix)/opt/gnu-sed"
  if [[ -d $_target ]]; then
    PATH="$_target/libexec/gnubin:$PATH"
    MANPATH="$_target/libexec/gnuman:$MANPATH"
  else
    echo 'You may want to `brew install gnu-sed`.'
  fi

  _target="$(brew --prefix)/opt/curl"
  if [[ -d $_target ]]; then
    PATH="$_target/bin:$PATH"
    MANPATH="$_target/share/man:$MANPATH"
  else
    echo 'You may want to `brew install curl`.'
  fi

  unset _target
fi

# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete # _ignored _correct _approximate
zstyle :compinstall filename '/Users/jonsurrell/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


HISTFILE=~/.histfile
HISTSIZE=3000
SAVEHIST=3000
setopt \
    APPEND_HISTORY         \
    EXTENDED_GLOB          \
    HIST_EXPIRE_DUPS_FIRST \
    HIST_FIND_NO_DUPS      \
    HIST_IGNORE_DUPS       \
    HIST_IGNORE_SPACE      \
    INTERACTIVE_COMMENTS   \
    NO_AUTO_CD             \
    SHARE_HISTORY

bindkey -v


#
# Key bindings
#

# Atuin - sqlite shell history https://atuin.sh/
if type atuin &> /dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^R' _atuin_search_widget # ctrl-r
else
  # ctrl-r history search
  bindkey '^R' history-incremental-pattern-search-backward
fi

# ctrl-n next
bindkey '^N' down-line-or-history

# ctrl-p previous
bindkey '^P' up-line-or-history

# ctrl-w delete word back
bindkey '^W' backward-kill-word

export KEYTIMEOUT=1

alias "cd.."='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

if [[ "$(\ls --version | head -n1)" =~ '^ls \(GNU coreutils\) 9\.' ]]; then
  alias ls="ls --classify=auto --color=auto --group-directories-first --hyperlink=auto"
else
  alias ls="ls --classify --color=auto --group-directories-first"
fi

# Subversion
alias svn-remove-missing='svn rm $(svn st | grep "^!" | cut -c 9-)'

#
# Git
# #
# Branch cleanup
alias git-clean-branches='git fetch --prune --quiet && git branch --list --format="%(if)%(worktreepath)%(then)%(worktreepath) %(upstream:track)%(end)" | awk '"'"'/\[gone\]/ { print $1 }'"'"' | xargs -r -n 1 git worktree remove --force ; git branch --list --format="%(refname:short) %(upstream:track)" | awk '"'"'/\[gone\]/ {print $1 }'"'"' | xargs -r git branch -D'

# Open current PR in browser
alias ghw='gh pr view --web'
# Print the current PR URL - handy to share, e.g. `ghu | pbcopy`
alias ghu='gh pr view --json url --jq .url'
# Create a new PR for the current branch
alias ghpr='gh pr create'
alias ghr='gh repo view --web'

alias fixdns="networksetup -listallnetworkservices | tail -n +2 | xargs -r -I{} sh -c "'"'"printf 'Setting DNS for service: {}'; networksetup -setdnsservers '{}' 9.9.9.9 149.112.112.112 2620:fe::fe 2620:fe::9 && echo ' ✅ OK!' || echo ' ⛔️ Non-zero exit!'"'"; sudo -p "Authorize to flush dns caches" sh -c "dscacheutil -flushcache; killall -HUP mDNSResponder"; sudo -K'
alias checkdns="networksetup -listallnetworkservices | tail -n +2 | xargs -r -I{} sh -c "'"'"echo 'DNS servers for {}:'; networksetup -getdnsservers '{}'; echo"'"'

alias darkmode='osascript -e '"'"'tell app "System Events" to tell appearance preferences to set dark mode to true'"'"'; [[ -n $TMUX ]] && (tmux set-option -g @catppuccin_flavor "frappe"; tmux run-shell ~/jon/catppuccin-tmux/catppuccin.tmux); pgrep nvim >/dev/null && (setopt NO_NOTIFY NO_MONITOR; lsof -p $(pgrep nvim | tr "\n" ",") | awk '"'"'$5 == "unix" && $8 ~ /nvim/ { print $8 } '"'"' | python -c '"'"'import sys
import neovim as n
servers = sys.stdin.read().splitlines()
def set_theme(s):
  nvim = n.attach("socket", path=s)
  nvim.command("set background='"'"'dark'"'"'")
  # nvim.command("colorscheme catppuccin")
  nvim.close()
list(map(set_theme, servers))'"'"') &|'

alias lightmode='osascript -e '"'"'tell app "System Events" to tell appearance preferences to set dark mode to false'"'"'; [[ -n $TMUX ]] && (tmux set-option -g @catppuccin_flavor "latte"; tmux run-shell ~/jon/catppuccin-tmux/catppuccin.tmux); pgrep nvim >/dev/null && (setopt NO_NOTIFY NO_MONITOR; lsof -p $(pgrep nvim | tr "\n" ",") | awk '"'"'$5 == "unix" && $8 ~ /nvim/ { print $8 } '"'"' | python -c '"'"'import sys
import neovim as n
servers = sys.stdin.read().splitlines()
def set_theme(s):
  nvim = n.attach("socket", path=s)
  nvim.command("set background='"'"'light'"'"'")
  # nvim.command("colorscheme catppuccin")
  nvim.close()
list(map(set_theme, servers))'"'"') &|'



# Set UTF-8 and English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Fix for GPG signing (git signed commits) "Inappropriate ioctl for device"
export GPG_TTY=$(tty)

# Set shell editors
if hash nvim 2>/dev/null; then
  export _VIM=nvim
else
  echo 'You may want to `brew install neovim`.'
  export _VIM=vim
fi

# Visual editor vim: noswap, nocompat, norc/plugins
export EDITOR="$_VIM --clean"
export VISUAL="$EDITOR"

# Git editor
export GIT_EDITOR="$_VIM -n -u NONE -i NONE -S $HOME/.dotfiles/config/git.nvimrc"
export GIT_SEQUENCE_EDITOR="$_VIM -n -u NONE -i NONE -S $HOME/.dotfiles/config/git-sequence.nvimrc"

# SVN editor
export SVN_EDITOR="$VISUAL"

unset _VIM

# Node / npm / yarn stuff
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export CHROMEDRIVER_SKIP_DOWNLOAD=true
export PUPPETEER_SKIP_DOWNLOAD=true

function svn-delta-diff {
  svn diff -x -w "$@" | delta | less -R
}

function serveitphp {
  php -S localhost:9090
}

function volta-install {
  volta install                  \
    @typescript/analyze-trace    \
    @wordpress/env               \
    @wp-now/wp-now               \
    @anthropic-ai/claude-code    \
    @biomejs/biome               \
    cssmodules-language-server   \
    devsense-php-ls              \
    intelephense                 \
    neovim                       \
    node@lts                     \
    npm                          \
    oxlint                       \
    pnpm                         \
    stylelint                    \
    stylelint-lsp                \
    typescript                   \
    typescript-language-server   \
    vscode-langservers-extracted \
    yaml-language-server         \
    yarn
}

function update-wp-stubs {
  _DIR="$HOME/.volta/tools/image/packages/intelephense/lib/node_modules/intelephense/lib/stub/wordpress"
  gh release -R php-stubs/wordpress-stubs download --archive=tar.gz -O - | tar xzvf - --directory "$_DIR" '*/wordpress-stubs.php'
  gh release -R php-stubs/wordpress-globals download --archive=tar.gz -O - | tar xzvf - --directory "$_DIR" '*/wordpress-globals.php'
  mv "$_DIR/"*/*.php "$_DIR"
  rmdir "$_DIR/"*/

  unset _DIR
}

export APPLE_SSH_ADD_BEHAVIOR=macos

# Source local shell config file
if [[ -f ~/.zshrc.local ]]; then
  . ~/.zshrc.local
fi

# vi et sw=4 ts=4 sts=4
