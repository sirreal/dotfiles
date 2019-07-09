" Always set in nvim
" set nocompatible
filetype off

set rtp+=~/.nvim/bundle/Vundle.vim
call vundle#begin("$HOME/.nvim/bundle")
  Plugin 'gmarik/Vundle.vim'

  Plugin 'Valloric/YouCompleteMe'

  Plugin 'editorconfig/editorconfig-vim'

  Plugin 'taglist.vim'

  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  Plugin 'NLKNguyen/papercolor-theme'

  " ST-like multiple cursors
  " Plugin 'terryma/vim-multiple-cursors'

  " Syntax
  " Plugin 'jelera/vim-javascript-syntax'
  " Plugin 'plasticboy/vim-markdown'

  Plugin 'mattn/emmet-vim'

  Plugin 'godlygeek/tabular'
  Plugin 'pangloss/vim-javascript'
  Plugin 'mxw/vim-jsx'

  " Plugin 'nathanaelkane/vim-indent-guides'
  Plugin 'ctrlpvim/ctrlp.vim'


  Plugin 'w0rp/ale'
  " Plugin 'scrooloose/syntastic'
  Plugin 'scrooloose/nerdtree'

  Plugin 'junegunn/vim-easy-align'

  Plugin 'tpope/vim-commentary'
  Plugin 'tpope/vim-fugitive'
  Plugin 'tpope/vim-repeat'
  Plugin 'tpope/vim-rsi'
  Plugin 'tpope/vim-surround'
  " Plugin 'tpope/vim-tbone'

  Plugin 'rust-lang/rust.vim'
  " Plugin 'mileszs/ack.vim'
  " Plugin 'lambdatoast/elm.vim'
  " Plugin 'STanAngeloff/php.vim'

  " Plugin 'shawncplus/phpcomplete.vim'

  Plugin 'leafgarland/typescript-vim'
  " Plugin 'Quramy/tsuquyomi'
  "   Plugin 'Shougo/vimproc.vim'
  " Plugin 'palantir/tslint'

  " Plugin 'FrigoEU/psc-ide-vim'
  " Plugin 'raichoo/purescript-vim'

  Plugin 'prettier/vim-prettier'

call vundle#end()            " required
filetype plugin indent on    " required

set termguicolors

syntax on

" Darken papercolor BG
let g:PaperColor_Dark_Override = { 'background': '#111111', 'cursorline': '#1f1f1f' }
set background=dark
colorscheme PaperColor

" Airline
let g:airline_theme='papercolor'
" let g:airline_powerline_fonts = 1
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
\ }
let g:airline_section_x = "" " Remove filetype section
let g:airline_section_y = "" " Remove file encoding section

" CtrlP
" let g:ctrlp_custom_ignore = '\.git\|\.svn\|\.DS_Store\|node_modules\|bower_components'
let g:ctrlp_user_command = "fd --full-path '%s' --hidden --follow --exclude '.git' --type file"

" Enhance command-line completion
set wildmenu

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
set directory=~/.nvim/swaps//,.
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
set listchars=tab:▸\ ,trail:␠,nbsp:␣
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
" DISABLE: Breaks JSX syntax (https://github.com/mxw/vim-jsx#frequently-asked-questions)
" let g:xml_syntax_folding=1
" au FileType xml setlocal foldmethod=syntax

" Strip trailing whitespace (,ss)
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
" noremap <leader>ss :call StripWhitespace()<CR>
"
" Enter cleans the search highlight
:nnoremap <CR> :nohlsearch<cr>

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

" Typescript checking
if !exists("g:ycm_semantic_triggers")
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']
" let g:syntastic_typescript_checkers = ['tsc']

"
" JavaScript
"
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_exec = 'eslint_d'
let g:jsx_ext_required = 0

let g:prettier#exec_cmd_path = '~/a8c/calypso/node_modules/.bin/prettier'
" let g:prettier#autoformat = 0
" let g:prettier#exec_cmd_async = 1
" let g:prettier#quickfix_enabled = 0
let g:prettier#quickfix_auto_focus = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.graphql,*.md,*.yaml,*.html PrettierAsync
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.json,*.graphql PrettierAsync

"
" Rust
"
let g:rustfmt_autosave = 1
" let g:syntastic_rust_checkers = ['cargo']

" EditorConfig play well with others
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Escape can be a pain
imap jj <Esc>

highlight ColorColumn ctermbg=lightred ctermfg=black guibg=lightred guifg=black


" JS line length
autocmd Filetype javascript setlocal colorcolumn+=101

" Remove - from keywords in some filetypes
autocmd Filetype javascript setlocal iskeyword+=-
autocmd Filetype scss setlocal iskeyword+=-
autocmd Filetype css setlocal iskeyword+=-

" ALE lint
let g:ale_fixers = {
\   'php': [ 'php_cs_fixer' ]
\}

" Some filetype settings
autocmd Filetype haskell setlocal ts=4 sw=4 sts=4 et colorcolumn+=81
autocmd Filetype markdown setlocal colorcolumn=101 tw=100 spell
autocmd Filetype purescript setlocal ts=2 sw=2 sts=2 et colorcolumn+=81
autocmd Filetype python setlocal ts=4 sw=4 sts=4 et colorcolumn+=81
autocmd Filetype php setlocal ts=4 sw=4 sts=4 noet colorcolumn+=101
