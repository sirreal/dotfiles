function vimupdate --description 'update vim plugins'
  set SHELL (which sh)
  vim +PluginInstall! +qall
  set SHELL (which fish)
end
