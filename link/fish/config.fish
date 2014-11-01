## Path
if test -d $HOME/go/bin
  set -gx PATH $HOME/go/bin $PATH
end

if test -d $HOME/.cabal/bin
  set -gx PATH $HOME/.cabal/bin $PATH
end

if test -d $HOME/bin
  set -gx PATH $HOME/bin $PATH
end

## Start session in tmux
tmux
