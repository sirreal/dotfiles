lua << EOLUA
require('init')
EOLUA

" Map W[a|A] Q[a|A] E to their lower-case variants
" https://blog.sanctum.geek.nz/vim-command-typos/
if has("user_commands")
    command! -bang -nargs=? -complete=file E e<bang> <args>
    command! -bang -nargs=? -complete=file W w<bang> <args>
    command! -bang -nargs=? -complete=file Wq wq<bang> <args>
    command! -bang -nargs=? -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif

" No ex mode
nnoremap Q <nop>

" autocmd BufWritePost plugins.lua source <afile> | PackerCompile
" autocmd BufWritePost treesitter.lua source <afile> | TSUpdate
autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}


nnoremap <C-p> <cmd>lua require('telescope.builtin').git_files()<CR>
inoremap <C-p> <cmd>lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>p <cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>

command! EditConfig :e ~/.config/nvim/init.vim

set laststatus=3

set nojoinspaces
set termguicolors

" Enhance command-line completion
set wildmenu

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
set shortmess=aotT

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
" nnoremap <CR> :nohlsearch<CR>

" Reset worthwhie title (not "Thanks for flying Vim")
let &titleold=getcwd()

" Up/down on wrapped lines
nmap j gj
nmap k gk

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure

let g:node_host_prog = system('volta which neovim-node-host | tr -d "\n"')

"
" Rust
"
let g:rustfmt_autosave = 1

" EditorConfig play well with others
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Escape can be a pain
imap jj <Esc>

" Line length ruler
highlight ColorColumn ctermbg=lightred ctermfg=black guibg=lightred guifg=black

" Some filetype settings
autocmd Filetype css setlocal iskeyword+=-
autocmd Filetype scss setlocal iskeyword+=-

autocmd Filetype haskell setlocal tabstop=4 shiftwidth=5 softtabstop=4 expandtab colorcolumn+=81
autocmd Filetype purescript setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab colorcolumn+=81
autocmd Filetype markdown setlocal colorcolumn=101 textwidth=100 spell

autocmd Filetype php setlocal autoindent tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab colorcolumn+=101

autocmd Filetype python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab colorcolumn+=81

autocmd Filetype javascript setlocal autoindent colorcolumn+=101
autocmd Filetype typescript setlocal autoindent colorcolumn+=101
autocmd Filetype typescriptreact setlocal autoindent colorcolumn+=101
