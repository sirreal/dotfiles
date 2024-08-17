" Vim config specific for commit messages
set tw=72
syntax on
set syntax=gitcommit
set colorcolumn=53
set spell
colorscheme darkblue
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey ctermfg=black guifg=black
highlight OverLength ctermbg=red guibg=red
match OverLength /\%73v.\+/
