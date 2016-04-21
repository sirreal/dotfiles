" Always set in nvim
" set nocompatible
filetype off

set rtp+=~/.nvim/bundle/Vundle.vim
call vundle#begin("$HOME/.nvim/bundle")
  Plugin 'gmarik/Vundle.vim'

  " fancy vim status line
  Plugin 'bling/vim-airline'

  " Theme
  " Plugin 'Lokaltog/vim-distinguished'
  " Plugin 'tomasr/molokai'
  Plugin 'NLKNguyen/papercolor-theme'

  " ST-like multiple cursors
  " Plugin 'terryma/vim-multiple-cursors'

  " Syntax
  " Plugin 'jelera/vim-javascript-syntax'
  " Plugin 'plasticboy/vim-markdown'

  " Completion
  Plugin 'Valloric/YouCompleteMe'
  Plugin 'mattn/emmet-vim'

  Plugin 'godlygeek/tabular'
  Plugin 'pangloss/vim-javascript'
  " Plugin 'mxw/vim-jsx'



  " Plugin 'nathanaelkane/vim-indent-guides'
  Plugin 'ctrlpvim/ctrlp.vim'

  Plugin 'php.vim'

  " Plugin 'rking/ag.vim'
  " Plugin 'marijnh/tern_for_vim'

  Plugin 'scrooloose/syntastic'
  Plugin 'scrooloose/nerdtree'

  " Plugin 'digitaltoad/vim-jade'

  Plugin 'junegunn/vim-easy-align'

  Plugin 'tpope/vim-surround'
  Plugin 'tpope/vim-commentary'
  Plugin 'tpope/vim-rsi'
  Plugin 'tpope/vim-repeat'
  Plugin 'tpope/vim-tbone'
  Plugin 'tpope/vim-sensible'

  " Plugin 'rust-lang/rust.vim'
  " Plugin 'mileszs/ack.vim'
  " Plugin 'lambdatoast/elm.vim'

call vundle#end()            " required
filetype plugin indent on    " required


syntax on

" Darken papercolor BG
let g:PaperColor_Dark_Override = { 'background': '#111111', 'cursorline': '#1f1f1f' }
set background=dark
colorscheme PaperColor

" Airline
" let g:airline_theme='PaperColor'
let g:airline_powerline_fonts = 1

" CtrlP
let g:ctrlp_custom_ignore = '\.git\|\.svn\|\.DS_Store\|node_modules'

" Enhance command-line completion
set wildmenu

" Allow cursor keys in insert mode
set esckeys

" Allow backspace in insert mode
" DEFAULT IN NVIM
" set backspace=indent,eol,start

" Optimize for fast terminal connections
" ALWAYS SET IN NVIM
" set ttyfast

" Use UTF-8 without BOM
set encoding=utf-8 nobomb

" Centralize backups, swapfiles and undo history
set backupdir=~/.nvim/backups
set directory=~/.nvim/swaps
if exists("&undodir")
  set undofile
  set undodir=~/.nvim/undo
  set undolevels=500
  set undoreload=500
endif
if exists("&undodir")
  set undofile
endif

" Respect modeline in files
set modeline
set modelines=4

" Enable line numbers
set number

" Make line numbers relative
set relativenumber

" Enable syntax highlighting
syntax on

" Highlight current line
set cursorline

" Show 'invisible' characters
"set lcs=tab:▸\ ,trail:·,nbsp:_,eol:¬
set listchars=tab:▸\ ,trail:·,nbsp:·
set list

"spaces not tabs
set expandtab
set shiftwidth=2
set softtabstop=2

" Highlight searches
set hlsearch

" Ignore case of searches
set ignorecase
set smartcase

" Highlight dynamically as pattern is typed
" NVIM DEFAULT
" set incsearch

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
set shortmess=atI

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

" Strip trailing whitespace (,ss)
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

if filereadable($HOME."/.vimrc.local")
  source $HOME/.vimrc.local
endif

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = 'eslint_d'

let g:tern#command = '~/.npm-globals/bin/tern'
let g:rustfmt_autosave = 0

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Some filetype settings
" set verbose=9
autocmd Filetype haskell setlocal ts=4 sw=4 sts=4 et
autocmd Filetype haskell highlight OverLength ctermbg=red ctermfg=white
autocmd Filetype haskell match OverLength /\%81v.\+/

autocmd Filetype python setlocal ts=4 sw=4 sts=4 et
autocmd Filetype python highlight OverLength ctermbg=red ctermfg=white
autocmd Filetype python match OverLength /\%80v.\+/

