" Vim config specific for GIT_EDITOR
set tw=72
syntax on
set spell
colorscheme darkblue

lua << EOF
  local filename = vim.fn.expand("%:p")
  if filename:match("COMMIT_EDITMSG") then
    vim.cmd([[
      set syntax=gitcommit
      set colorcolumn=53
      highlight ColorColumn ctermbg=lightgrey guibg=lightgrey ctermfg=black guifg=black
      highlight OverLength ctermbg=red guibg=red
      match OverLength /\%73v.\+/
    ]])
  end
  if filename:match("config") or filename:match(".gitconfig") then
    vim.cmd([[
      set syntax=git_config
      set colorcolumn=53
    ]])
  end
EOF
