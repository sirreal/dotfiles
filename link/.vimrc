set nocompatible
filetype off

set t_Co=256

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

syntax on

set background=dark
colorscheme zellner

" Enhance command-line completion
set wildmenu

" Allow cursor keys in insert mode
set esckeys

" Allow backspace in insert mode
set backspace=indent,eol,start

" Optimize for fast terminal connections
set ttyfast

" Use UTF-8 without BOM
set encoding=utf-8 nobomb

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
  set undofile
  set undodir=~/.vim/undo
  set undolevels=500
  set undoreload=500
endif

" Respect modeline in files
set modeline

" Enable line numbers
set number

" Make line numbers relative
set relativenumber

" Enable syntax highlighting
syntax on

" Highlight current line
set cursorline

" Show 'invisible' characters
set listchars=tab:▸\ ,trail:␠,nbsp:␣
set list

" Guess tabs/spaces
set smarttab
set softtabstop=4
set tabstop=4

" Highlight searches
set hlsearch

" Highlight dynamically as pattern is typed
set incsearch

" Ignore case of searches
set ignorecase
set smartcase " unless there's mixed caps in search ;)

" Always show status line
set laststatus=2

" Disable auto-mouse in all modes
set mouse-=a

" Disable error bells
set noerrorbells

" Don’t reset cursor to start of line when moving around.
set nostartofline

" Show the cursor position
set ruler

" Don’t show the intro message when starting Vim
set shortmess=attI

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it’s being typed
set showcmd

" Start scrolling three lines before the horizontal window border
set scrolloff=3

" XML filetype folding
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax

" Strip trailing whitespace (<leader>ss)
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
" noremap <leader>ss :call StripWhitespace()<CR>

" Reset worthwhie title (not "Thanks for flying Vim")
let &titleold=getcwd()

" Up/down on wrapped lines
nmap j gj
nmap k gk

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure

" Escape can be a pain
imap jj <Esc>

" Line length ruler
highlight ColorColumn ctermbg=lightred ctermfg=black guibg=lightred guifg=black

" Some filetype settings
autocmd Filetype css setlocal iskeyword+=-
autocmd Filetype scss setlocal iskeyword+=-

autocmd Filetype haskell setlocal ts=4 sw=4 sts=4 et colorcolumn+=81
autocmd Filetype purescript setlocal ts=2 sw=2 sts=2 et colorcolumn+=81

autocmd Filetype markdown setlocal colorcolumn=101 tw=100 spell

autocmd Filetype php setlocal ts=4 sw=4 sts=4 noet colorcolumn+=101

autocmd Filetype python setlocal ts=4 sw=4 sts=4 et colorcolumn+=81

autocmd Filetype javascript setlocal colorcolumn+=101 iskeyword+=-
autocmd Filetype typescript setlocal colorcolumn+=101
autocmd Filetype typescriptreact setlocal colorcolumn+=101
