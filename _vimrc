" New buffer filetype
autocmd BufEnter * if &filetype == "" | setlocal ft=sql | endif
autocmd BufEnter *.txt setlocal formatoptions=aw2tq
" set iskeyword not working as expected without that
autocmd FileType sql setlocal iskeyword=@,48-57,_,192-255
autocmd FileType txt setlocal iskeyword=@,48-57,_,192-255
"
set encoding=utf-8
set fileformat=unix
"set guifont=Consolas:h11:cRUSSIAN
" set guifont=Inconsolata:h12:cRUSSIAN
set guifont=DejaVu_Sans_Mono:h10:cRUSSIAN
set ignorecase
set smartcase
set incsearch
" dont use @ as file name part. Useful for sql script: @@script_file.sql
set isfname-=@-@

set iskeyword=@,48-57,_,192-255
set nocompatible
set nohlsearch
set number
" path
set path+=$DPR_WD
set path+=$DREP_WD
" add suffixes to gf and other command. Search sql by default
set suffixesadd+=.sql
" wildmode/menu
set wildmode=longest,list
set nowildmenu
" au BufEnter,VimEnter * cd $MY_VIM_WORKING_DIR
" source $VIMRUNTIME/vimrc_example.vim
" source $VIMRUNTIME/mswin.vim
" behave mswin
" session autosave
let g:session_autoload='yes'
let g:session_autosave='yes'
" netrw
let g:netrw_cygwin= 0
let g:netrw_scp_cmd = 'C:\Windows\putty\pscp.exe -batch -q -scp'
let g:netrw_silent = 0
let g:netrw_sftp_cmd= 'C:\Windows\putty\psftp.exe'

" tabs
set expandtab
set shiftwidth=2
set tabstop=2

syntax enable
set background=dark
"
" vim-plug
call plug#begin()
  Plug 'morhetz/gruvbox'
  Plug 'xolox/vim-misc'
  Plug 'xolox/vim-session'
  Plug 'nanotech/jellybeans.vim'
  Plug 'endel/vim-github-colorscheme'
  Plug 'therubymug/vim-pyte'
  " Plug 'altercation/vim-colors-solarized'
  " snipmate
  Plug 'MarcWeber/vim-addon-mw-utils'
  Plug 'vim-scripts/tlib'
  Plug 'garbas/vim-snipmate'
  Plug 'jlanzarotta/bufexplorer'
call plug#end()

" colorscheme solarized " my addition
" colorscheme gruvbox " my addition
" colorscheme jellybeans " my addition
colorscheme pyte
" colorscheme default

" diff for windows
"
"set diffexpr=MyDiff()
"function! MyDiff()
"  let opt = '-a --binary '
"  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
"  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
"  let arg1 = v:fname_in
"  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
"  let arg2 = v:fname_new
"  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
"  let arg3 = v:fname_out
"  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
"  let eq = ''
"  if $VIMRUNTIME =~ ' '
"    if &sh =~ '\\<cmd'
"      let cmd = '""' . $VIMRUNTIME . '\diff"'
"      let eq = '"'
"    else
"      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
"    endif
"  else
"    let cmd = $VIMRUNTIME . '\diff'
"  endif
"  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction

" Maximize vim http://vim.wikia.com/wiki/Maximize_or_set_initial_window_size
if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window.
  set lines=999 columns=999
else
  " This is console Vim.
  "  if exists("+lines")
  "    set lines=50
  "  endif
  "  if exists("+columns")
  "    set columns=100
  "  endif
endif

" abbreveations
cabbr bce browse confirm edit
cabbr bcs browse confirm saveas

" dictionary 
set dictionary+=/home/velikikh/oracle/scripts/sql_hint.dict

" leaders
let mapleader=','
let maplocalleader='\\'

" fast saving
nnoremap <leader>w :w!<cr>
" map to close a window
nnoremap <leader>q <c-w>q
" edit vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" sourcing vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" command mode mappings. Marc Weber
cmap >fn <c-r>=expand('%:p')<cr>
cmap >fd <c-r>=expand('%:p:h').'/'<cr>
" command mode mappings for expand %% to the path of active buffer. Practical Vim. 
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" insert mode mappings
inoremap jj <Esc>
" inoremap s* select * from 

" buffers mappings. Practical Vim.
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

" Vimscripts file settings ----------------------{{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup end
" }}}
" SQL file settings ----------------------{{{
augroup filetype_sql
  autocmd!
  autocmd FileType sql setlocal formatprg=java\ org.orasql.SQLBeautifier
augroup end
" }}}

" My function: convert list of strings to select union all
function! Vma_select_list() range
	exe a:firstline . "," . a:lastline . 
	\ "s/\\v(.*)" .
	\ "/\\=\"select q'[\" . submatch(0) . \"]' c from dual\""
	\ " . ((line('.')==" . a:lastline . ") ? \"\" : \" union all\")/"
endfunction
" Convert spaces to a0 - non-breakable spaces. Useful to paste to Lync
function! Vma_space2a0()
  %s/ /\=nr2char(160)/g
endfunction
