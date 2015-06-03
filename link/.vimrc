set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

" fancy vim status line
Plugin 'bling/vim-airline'

" Theme
Plugin 'Lokaltog/vim-distinguished'
Plugin 'tomasr/molokai'

" ST-like multiple cursors
" Plugin 'terryma/vim-multiple-cursors'

" Syntax
" Plugin 'jelera/vim-javascript-syntax'
" Plugin 'plasticboy/vim-markdown'

" Completion
Plugin 'Valloric/YouCompleteMe'

Plugin 'godlygeek/tabular'
" Plugin 'pangloss/vim-javascript'
" Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'kien/ctrlp.vim'

Plugin 'php.vim'
let g:ctrlp_custom_ignore = '\.git\|\.svn\|\.DS_Store\|node_modules'

" Plugin 'rking/ag.vim'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'

Plugin 'digitaltoad/vim-jade'

Plugin 'junegunn/vim-easy-align'

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line



set t_Co=256
syntax on
set background=dark
:silent! colorscheme distinguished


" Enhance command-line completion
set wildmenu

" Allow cursor keys in insert mode
set esckeys

" Allow backspace in insert mode
set backspace=indent,eol,start

" Optimize for fast terminal connections
set ttyfast

" Add the g flag to search/replace by default
set gdefault

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
if exists("&undodir")
  set undofile
endif

" Respect modeline in files
set modeline
set modelines=4

" Enable line numbers
set number

" Enable syntax highlighting
syntax on

" Highlight current line
set cursorline

" Show “invisible” characters
"set lcs=tab:▸\ ,trail:·,nbsp:_,eol:¬
set listchars=tab:▸\ ,trail:·,nbsp:·
set list

"spaces not tabs
set expandtab
set shiftwidth=2
set softtabstop=2

" Highlight searches
" set hlsearch

" Ignore case of searches
" set ignorecase

" Highlight dynamically as pattern is typed
set incsearch

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

if filereadable($HOME."/.vimrc.local")
  source $HOME/.vimrc.local
endif
