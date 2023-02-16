" Vim config specific for commit messages
set tw=72
set background=dark
syntax on
set syntax=gitcommit
set colorcolumn=53
set spell
colorscheme tokyonight
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey ctermfg=black guifg=black
highlight OverLength ctermbg=red guibg=red
match OverLength /\%73v.\+/
