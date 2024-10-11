let mapleader=" "
syntax on
set number
set norelativenumber
set cursorline
set wrap
set showcmd
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase

set nocompatible
set scrolloff=5
set autoread
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on

" ===
" === Editor behavior
" ===
" Better tab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
" set list
" set listchars=tab:▸\ ,trail:▫
set scrolloff=5

" Prevent auto line split
set wrap
set tw=0

set indentexpr=
" Better backspace
set backspace=indent,eol,start

set foldmethod=indent
set foldlevel=99

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" ===
" === Status/command bar
" ===
set laststatus=2
set autochdir
set showcmd
set formatoptions-=tc

" Show command autocomplete
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu                                                 " show a navigable menu for tab completion
set wildmode=longest,list,full

" Searching options
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase

set tags=tags;/

" ===
" === Restore Cursor Position
" ===
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

noremap K 5k
noremap J 5j
noremap <LEADER><CR> :nohlsearch<CR>

" Duplicate words
map <LEADER>fd /\(\<\w\+\>\)\_s*\1

map s <nop>
map S :w<CR>
map Q :q<CR>
map R :source ~/.vimrc<CR>

map <LEADER>rc :e ~/.vimrc<CR>

map sl :set splitright<CR>:vsplit<CR>
map sh :set nosplitright<CR>:vsplit<CR>
map sk :set nosplitbelow<CR>:split<CR>
map sj :set splitbelow<CR>:split<CR>

map <LEADER>l <C-w>l
map <LEADER>h <C-w>h
map <LEADER>k <C-w>k
map <LEADER>j <C-w>j

map <up> :res +5<CR>
map <down> :res -5<CR>
map <left> :vertical resize-5<CR>
map <right> :vertical resize+5<CR>

map tu :tabe<CR>
map ti :tabe %<CR>
map th :-tabnext<CR>
map tl :+tabnext<CR>

" Press space twice to jump to the next '<++>' and edit it
" map <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>c4G

map <LEADER><LEADER>   <Esc>/TBR<CR>:nohlsearch<CR>
map <LEADER>sc :set spell!<CR>

map <LEADER>a  <Esc>opr_info("[gz-debug]: %s\t%d\n", __func__, __LINE__);<CR><Esc>
map <LEADER>r  <Esc>a"\033[0;31m" "\033[0m"<Esc>
" map <LEADER>a  <Esc>oprintf("[gz-debug]: %s\t%d\n", __func__, __LINE__);<CR><Esc>
map <LEADER>t  <Esc>o/**<CR>TBR<CR>/<Esc>
map <LEADER>d  <Esc>:ALEDetail<CR>
map <LEADER>c  <Esc>o```<CR>

map tx : r !figlet

call plug#begin('~/.vim/plugged')

" Error checking
Plug 'dense-analysis/ale'

" Latest nodejs should be installed as requirement, btw nodejs should be
" reinstalled in ubuntu
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

colorscheme desert

let g:coc_disable_startup_warning = 1
