""""""""""""""""""""""""""""""""""
"   Usability
""""""""""""""""""""""""""""""""""

set smarttab
set tabstop=4
set shiftwidth=4
" use spaces instead of tabs
set expandtab

""""""""""""""""""""""""""""""""""
"   Interface
""""""""""""""""""""""""""""""""""

" Line number settings
set number

" Make comments italic
highlight comment cterm=italic gui=italic

""""""""""""""""""""""""""""""""""
"   Plugins
""""""""""""""""""""""""""""""""""

call plug#begin()
    Plug 'tomasiser/vim-code-dark' " vscode colortheme
    Plug 'bling/vim-airline'       " bottom status bar
    Plug 'Yggdroot/indentLine'     " line indentation visualization
    Plug 'scrooloose/nerdtree'     " side directory viewer
call plug#end()

set number
syntax on

set termguicolors
colorscheme codedark

" --------- bling/vim-airline settings -------------
" always show statusbar
set laststatus=2
" use powerline font extras (arrows)
let g:airline_powerline_fonts=1
" show airline for tabs
let g:airline#extension#tabline#enabled=1

" --------- indentLine settings -------------------
let g:indentLine_showFirstLevelIndent=1
let g:indentLine_setColors=0

