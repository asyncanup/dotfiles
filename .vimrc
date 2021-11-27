" Philosophy
" Ctrl commands are most commonly used, generally cyclable commands
" Alt commands are uncommonly used, generally cyclable commands
" <leader> commands are commonly used, generally non-cyclable commands
"
" Order of sections is important. Plugin custom mappings and initialization
" variables come before loading plugins because some plugin customizations
" require that in order to not set default key mappings.
" Environment and editor (non-plugin) mappings come after loading plugins
" so that they are not overridden by key mappings set by plugins

" ---- environment settings ----

" break compatibility with old vim
set nocompatible

" reload files on change in file system
set autoread
autocmd FocusGained,BufEnter * :silent! checktime

" allow case insensitive searches by default
set ignorecase
set smartcase

" smart indenting
set smartindent

" split screen to the right and bottom
set splitbelow
set splitright

" line numbers and their color
set number
set relativenumber

" allow navigating away from edited buffers
set hidden

" lazy redraw so screen doesn't flicker on fast changes
set lazyredraw

" don't add 2 spaces after a full stop when joining lines
set nojoinspaces

" default text width
set textwidth=80

" disable mouse scroll, otherwise vim in screen eats 1 <esc> press
set mouse=

" expand tabs to spaces
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

" show extra symbol at end of line
" so that shortcuts can depend on <esc>l in insert mode
set virtualedit=onemore

" backups
set backup
set backupdir=~/.vim/backup/
set writebackup
set backupcopy=yes
" meaningful backup name, ex: filename@2015-04-05.14:59
au BufWritePre * let &bex = '@' . strftime("%F.%H:%M")

" persistent undo
set undofile
set undodir=~/.vim/undodir

" set path where tabfind looks for file names
set path=.,

" switching to other buffers opens the relevant window if available
set switchbuf=usetab,newtab

" vim screen update time is relevant for signify (git)
set updatetime=100

" highlight cursor line
set cursorline

" set leader key
let mapleader = ","

" neovim python host prorams
let g:python3_host_prog="$HOME/.pyenv/versions/neovim3/bin/python"
let g:python_host_prog="$HOME/.pyenv/versions/neovim2/bin/python"

" ---- plugin settings ----

" airline statusline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#ctrlspace_show_tab_nr = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
let airline#extensions#tabline#current_first = 1
let g:airline_powerline_fonts = 1
let g:airline_left_alt_sep = ''
let g:airline#extensions#default#section_truncate_width = {
    \ 'b': 90,
    \ 'x': 90,
    \ 'y': 100,
    \ 'z': 90,
    \ 'warning': 60,
    \ 'error': 60,
    \ }
let g:airline#extensions#default#layout = [
    \ [ 'a', 'c' ],
    \ [ 'b', 'z', 'error', 'warning' ]
    \ ]
let g:airline#extensions#branch#displayed_head_limit = 20

" js code formatter config
let g:prettier#autoformat = 0
let g:prettier#exec_cmd_path = ""
let g:prettier#config#tab_width = 4
nnoremap <silent> <leader>p :PrettierAsync<cr>
" autocmd BufWritePost *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" YouComplete me config
let g:ycm_always_populate_location_list = 1
let g:ycm_open_loclist_on_ycm_diags = 0

" populate location list with errors
nnoremap <leader>e :YcmDiags<cr>:close<cr>:lnext<cr>:lprev<cr><c-w>_zz

" rename a variable
nnoremap <c-r> :YcmCompleter RefactorRename<space>

" go to definition
nnoremap <enter> :YcmCompleter GoTo<cr>zt

" go to references
nnoremap <silent> yr :YcmCompleter GoToReferences<cr>:cnext<cr>:cprev<cr>

" try to fix issue
nnoremap yx :YcmCompleter FixIt<cr>

" restart type server
nnoremap <leader>yr :YcmRestartServer<cr>

" format code
nnoremap <leader>yf :YcmCompleter Format<cr>

" python code formatter config
" autocmd BufWritePre *.py YAPF

" fullscreen zen writing mode
function! SetWritingMode()
    Goyo 100
    set tw=0
    set linebreak
    nnoremap j gj
    nnoremap k gk
    nnoremap 0 g0
    nnoremap $ g$
    nnoremap I g0i
    nnoremap A g$i
    nnoremap C cg$
    nnoremap D dg$
    nnoremap d0 dg0
    nnoremap d$ dg$
    nnoremap cc g0cg$
    nnoremap dd g0dg$a<bs><esc>j0
endfunction
command! -bang WritingMode call SetWritingMode()
nnoremap <silent> <a-g> :WritingMode<cr>

" show commit history for current file
nnoremap <silent> gm :BCommits<cr>

" fzf default window layout
let g:fzf_layout = { 'down': '~60%' }

" cleaner look for FZF, removes the redundant statusline that says TERMINAL
if has('nvim')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
endif

" allows deleting buffers en-masse
function! SortBufsByLastOpened(b1, b2)
  let t1 = get(g:fzf#vim#buffers, split(a:b1)[0], -1)
  let t2 = get(g:fzf#vim#buffers, split(a:b2)[0], -1)
  return t1 < t2
endfunction
function! BufsByLastOpened()
  redir => ls_output
  silent ls
  redir END
  let buf_list = split(substitute(ls_output, '"', '', 'g'), "\n")
  let bufs_without_self = filter(buf_list, { _, item -> split(item)[0] != bufnr('') })
  let names_list = map(bufs_without_self, { _, item -> substitute(item, 'line \d*$', '', '') })
  let sorted_by_last_opened = sort(names_list, "SortBufsByLastOpened")
  return sorted_by_last_opened
endfunction

command! DeleteBuffers call fzf#run(fzf#wrap({
  \ 'source': BufsByLastOpened(),
  \ 'sink*': { lines -> execute('bwipeout '.join(map(lines, {_, line -> split(line)[0]}))) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))
nnoremap <a-s-x> :DeleteBuffers<cr>

" find tab with file and switch to it, or open new tab with file
command! DropToBufferWindow call fzf#run(fzf#wrap({
  \ 'source': BufsByLastOpened(),
  \ 'sink*': { lines -> execute('drop ' . matchstr(lines[0], '[^ ]* *$') . ' | resize 1000') },
  \ 'options': ''
\ }))
nnoremap <s-tab> :DropToBufferWindow<cr>

" drop to last buffer in its window
command! DropToLastBufferWindow execute('drop ' . matchstr(BufsByLastOpened()[0],'[^ ]* *$'))
nnoremap <silent> <c-^> :DropToLastBufferWindow<cr><c-w>_

" search in open buffers
nnoremap <silent> <c-f> :Lines<cr>

" search in current buffer
nnoremap <silent> <a-/> :BLines<cr>

" search in project, with rg cli arguments
" https://github.com/junegunn/fzf.vim/issues/596#issuecomment-538830525
" https://github.com/junegunn/fzf.vim/issues/837#issuecomment-615995881
command! -bang -nargs=* PRg call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case '.(<q-args>), 1,
  \   {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2], 'options':['--layout=reverse-list']},
  \   <bang>0)

nnoremap <silent> <bslash> :Rg<cr>
nnoremap <silent> \| :Rg <c-r>=expand('<cword>')<cr><cr>
vnoremap <silent> <bslash> y<esc>:Rg <c-r>=escape(@",'\{(')<cr><cr>

" search for personal notes
nnoremap <silent> gn :Rg :note:<cr>

" git operations
nnoremap gb :Git blame<cr>

" git commands
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit -v<cr>

" git hunk jumping
nmap <a-l> <plug>(signify-next-hunk)
nmap <a-h> <plug>(signify-prev-hunk)
nnoremap <silent> <a-;> :SignifyHunkDiff<cr>
nnoremap <a-d> :SignifyDiff<cr>
nnoremap <a-u> :SignifyHunkUndo<cr>
omap ic <plug>(signify-motion-inner-pending)
xmap ic <plug>(signify-motion-inner-visual)
omap ac <plug>(signify-motion-outer-pending)
xmap ac <plug>(signify-motion-outer-visual)

" stop rooter from changing directory automatically
let g:rooter_manual_only = 1
nnoremap <a-c> :Rooter<cr>

" show Vista file outline
nnoremap <a-s-t> :Vista!!<cr><c-w>15>

" nnn file manager
let g:nnn#layout = { 'down': '~35%' }
let g:nnn#action = {
      \ '<c-t>': 'tab split',
      \ '<c-x>': 'split',
      \ '<c-v>': 'vsplit' }
nnoremap <a-n> :NnnPicker %:p:h<cr>

" fzf file selection
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

" disable vim features on large files
let g:LargeFile = 10

" ultisnips
let g:UltiSnipsExpandTrigger = '<c-t>'
let g:UltiSnipsJumpForwardTrigger = '<c-k>'

" ctrl-space window, tab, workspace management
let g:CtrlSpaceDefaultMappingKey = '<space> '
let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
let g:CtrlSpaceSaveWorkspaceOnExit = 1
nnoremap <a-s-w> :CtrlSpaceSaveWorkspace<cr>

" elm
let g:ycm_semantic_triggers = {
  \ 'elm' : ['.'],
  \}

nnoremap <leader>b :ElmMake<cr>

" git commands via fugitive
nnoremap gs :Gstatus<cr><c-w>L
nnoremap gP :Gpush<cr>
nnoremap gM :Gvsplit master:%<cr>
nnoremap gO :Gvsplit @:%<cr>

" ---- load plugins ----

" load vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" load plugins using vim-plug
call plug#begin('~/.vim/bundle')

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'tpope/vim-commentary'
Plug 'flazz/vim-colorschemes'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'mcchrish/nnn.vim'
Plug 'vim-scripts/LargeFile'
Plug 'pgr0ss/vim-github-url'
Plug 'nelstrom/vim-visual-star-search'
Plug 'liuchengxu/vista.vim'
Plug 'vim-ctrlspace/vim-ctrlspace'
Plug 'grailbio/bazel-compilation-database'
Plug 'gabrielelana/vim-markdown'
Plug 'PeterRincker/vim-argumentative'
Plug 'zyedidia/literate.vim', { 'for': 'lit' }
Plug 'ElmCast/elm-vim', { 'for': 'elm' }
Plug 'prettier/vim-prettier', { 'for': ['javascript', 'typescript', 'css', 'json', 'markdown', 'yaml', 'html'] }
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }
Plug 'w0rp/ale', { 'on': 'ALEToggle' }
Plug 'vimwiki/vimwiki'
Plug 'dominikduda/vim_current_word'
" ---- place to add new plugins ----

" Macbook M1 chip requires the --system-libclang flag
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --clangd-completer --ts-completer --system-libclang' }

if has('nvim') || has('patch-8.0.902')
  Plug 'kshenoy/vim-signature'
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

call plug#end()

" ---- settings that require plugins loaded ----

" file finder
command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
nnoremap <silent> <c-p> :GFiles<cr>
nnoremap <silent> <c-t> :call fzf#run({'source': 'fd -H --no-ignore-vcs', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <silent> <a-t> :call fzf#run({'source': 'fd -H --no-ignore-vcs . <c-r>=expand("%:h")<cr>', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <silent> <c-o> :History<cr>
nnoremap <silent> <tab> :Buffers<cr>
nnoremap <silent> <leader><tab> :Files %:p:h<cr>

" command history
nnoremap <silent> <a-:> :History:<cr>

" move to tab number
nnoremap <a-1> 1gt
nnoremap <a-2> 2gt
nnoremap <a-3> 3gt
nnoremap <a-4> 4gt
nnoremap <a-5> 5gt
nnoremap <a-6> 6gt
nnoremap <a-7> 7gt
nnoremap <a-8> 8gt
nnoremap <a-9> 9gt
tnoremap <a-1> <c-\><c-n>1gt
tnoremap <a-2> <c-\><c-n>2gt
tnoremap <a-3> <c-\><c-n>3gt
tnoremap <a-4> <c-\><c-n>4gt
tnoremap <a-5> <c-\><c-n>5gt
tnoremap <a-6> <c-\><c-n>6gt
tnoremap <a-7> <c-\><c-n>7gt
tnoremap <a-8> <c-\><c-n>8gt
tnoremap <a-9> <c-\><c-n>9gt

" fzf command history feature
let g:fzf_history_dir = '~/.fzf-history'

function! s:update_colors()
  " mark colors
  highlight SignatureMarkText ctermfg=gray guifg=gray ctermbg=NONE guibg=NONE cterm=NONE gui=NONE

  " signify colors (must be after color scheme)
  highlight SignifySignAdd    ctermfg=magenta guifg=#00ff00 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE
  highlight SignifySignDelete ctermfg=blue    guifg=#ff0000 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE
  highlight SignifySignChange ctermfg=green   guifg=#ffff00 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE

  " line number color (overrides colorscheme)
  highlight CursorLineNr ctermfg=blue

  " vim-current-word highlight color
  highlight CurrentWord ctermbg=237
  highlight CurrentWordTwins ctermbg=237

endfunction
autocmd User AirlineAfterTheme call s:update_colors()

" color scheme
colorscheme PaperColor
set bg=dark

" ---- editor commands ----
" included here so that plugins can't overwrite bindings

" move to first character of line
nnoremap g0 g^

" make C not overwrite the copy register
nnoremap C "_C

" open a new empty tab
nnoremap <leader>tt :tabe<cr>

" indent a markdown bullet point in input mode
inoremap <a-]> <esc>0i<space><space><esc>A
inoremap <a-[> <esc>g^i<bs><esc>A

" navigate panels (windows)
nnoremap <up> <c-w>k
nnoremap <down> <c-w>j
nnoremap <left> <c-w>h
nnoremap <right> <c-w>l

nnoremap <s-up> <c-w>k<c-w>_
nnoremap <s-down> <c-w>j<c-w>_
nnoremap <s-left> <c-w>h<c-w>\|
nnoremap <s-right> <c-w>l<c-w>\|

inoremap <s-up> <esc><c-w>k<c-w>_
inoremap <s-down> <esc><c-w>j<c-w>_
inoremap <s-left> <esc><c-w>h
inoremap <s-right> <esc><c-w>l

let c = 1
while c <= 10
  execute "nnoremap " . c . "<s-up> " . c . "<c-w>k<c-w>_"
  execute "nnoremap " . c . "<s-down> " . c . "<c-w>j<c-w>_"
  execute "nnoremap " . c . "<s-left> " . c . "<c-w>=<c-w>h"
  execute "nnoremap " . c . "<s-right> " . c . "<c-w>=<c-w>l"
  let c += 1
endwhile

" stack windows horizontally or vertically
nnoremap <silent> <a-bslash> :windo wincmd L<cr>
nnoremap <silent> <a-\|> :windo wincmd J<cr>

" when searching locally, reposition found location to center of screen
nnoremap n n
nnoremap N N

" enter a line above in insert mode
inoremap <c-o> <esc>O

" bash movement shortcuts in insert mode
" `^ moves cursor to the position going out of insert mode
" <c-u> already works
inoremap <c-e> <esc>A
cnoremap <c-e> <end>
inoremap <c-a> <esc>I
cnoremap <c-a> <home>
inoremap <a-b> <esc>`^bi
cnoremap <a-b> <s-left>
inoremap <a-f> <esc>`^wi
cnoremap <a-f> <s-right>
inoremap <a-d> <esc>`^dwi
" backspace: does not go beyond the previous line
inoremap <c-h> <esc>l"_dbi
cnoremap <c-h> <c-w>
inoremap <c-k> <esc>lDi

" go to previous and next cursor locations across buffers
nnoremap - <c-o>
nnoremap _ <c-i>

" go to previous and next edit locations in same buffer
nnoremap <a--> g;
nnoremap <a-_> g,

" use semicolon for command prompt (no shift key)
nnoremap ; :
vnoremap ; :

" quickfix shortcuts
nnoremap <silent> <a-j> :cnext<cr><c-w>_
nnoremap <silent> <a-k> :cprev<cr><c-w>_
nnoremap <a-o> :copen<cr>

" location list shortcuts
nnoremap <silent> <a-s-j> :lnext<cr>zz
nnoremap <silent> <a-s-k> :lprev<cr>zz
nnoremap <a-s-o> :lopen<cr>
nnoremap <a-s-l> :ll<cr>

" shortcuts to save files
nnoremap <c-s> :w<cr>
inoremap <c-s> <esc>:w<cr>
vnoremap <c-s> <esc>:w<cr>

nnoremap <a-s-s> :w!<cr>
inoremap <a-s-s> <esc>:w!<cr>
vnoremap <a-s-s> <esc>:w!<cr>

nnoremap <a-s> :wa<cr>
inoremap <a-s> <esc>:wa<cr>
vnoremap <a-s> <esc>:wa<cr>

" easier redo
nnoremap U <c-r>

" unset last search highlight
nnoremap <esc> :noh<cr>:<bs>
inoremap <c-j> <esc>
cnoremap <c-j> <esc>

" switch to next buffer
nnoremap <silent> L :CtrlSpaceGoDown<cr>
nnoremap <silent> H :CtrlSpaceGoUp<cr>

" reload vimrc
nnoremap <a-r> :source ~/.vimrc<cr>
inoremap <a-r> <esc>:source ~/.vimrc<cr>
" reload only the visually selected text
nnoremap <a-s-r> yy:<c-r>"<cr>
vnoremap <a-r> y:<c-r>"<cr>

" to reload a file from file system
nnoremap <leader>r :e<cr>

" join lines
nnoremap <leader>j J
inoremap <a-j> <esc>kJgi

" close window, not tab
function! CloseWindow()
  if winnr("$") != 1
    close
  else
    echo "Last window in tab"
  endif
endfunction
nnoremap <silent> <c-q> :call CloseWindow()<cr>

" close tab, all windows
function! CloseTab()
  if tabpagenr("$") == 1
    echo "Last tab in vim"
  elseif tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
    tabclose | tabprev
  else
    tabclose
  endif
endfunction
nnoremap <silent> <a-q> :call CloseTab()<cr>

" quit dirty window/tab
nnoremap <c-a-q> :q!<cr>

" quit vim, if not dirty
nnoremap <a-s-q> :qall<cr>

" bring current line to middle
nnoremap zm <esc>7kzt7j

" show internal output of ex command in a new tab
" from https://vim.fandom.com/wiki/Capture_ex_command_output
function! CommandOutput(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echo "no ex output"
  else
    " use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction
command! -nargs=+ -complete=command CommandOutput call CommandOutput(<q-args>)

" close buffer
nnoremap <silent> <c-x> :b #<cr>:bd #<cr>
nnoremap <silent> <a-x> :bp<cr>:bd #<cr>

" remap digraph key to <c-d>.
" so that <c-k> can be similar bash default (delete till end of line)
inoremap <c-d> <c-k>

" regular clipboard
nnoremap <c-v> "+p
nnoremap <c-y> 0"+y$:echo 'Copied: '.@+<cr>
nnoremap <a-y> gg"+yG``
nnoremap <a-s-y> "+yiW:echo 'Copied: '.@+<cr>
inoremap <silent> <c-v> <esc>:set paste<cr>"+p:set nopaste<cr>a
vnoremap <c-y> "+y
vnoremap <c-x> "+d
vnoremap <c-v> d"+P

" open files from the same directory
nnoremap <c-e> :edit <c-r>=expand("%:p:h") . "/" <cr>
nnoremap <a-e> :vsplit <c-r>=expand("%:p:h") . "/" <cr>
nnoremap <a-s-e> :split <c-r>=expand("%:p:h") . "/" <cr>

" paste and nopaste
nnoremap <silent> <a-p>p :set invpaste<cr>

" install newly added plugins
nnoremap <a-p>i :w<cr>:source ~/.vimrc<cr>:PlugInstall<cr>

" cleanup removed plugins
nnoremap <a-p>c :w<cr>:source ~/.vimrc<cr>:PlugClean<cr>

" marks
nnoremap J ]`zz
nnoremap K [`zz

" use rg if available to search for text
if executable('rg')
  " Use rg via grep
  set grepprg=rg\ --vimgrep
endif

" change current directory to current file's parent
nnoremap <c-c> :cd %:p:h<cr>

" make g; and g, go forward and backward for character searches
nnoremap g; ;
nnoremap g, ,

" move the line up or down
nnoremap <silent> <c-j> :m .+1<cr>
nnoremap <silent> <c-k> :m .-2<cr>
vnoremap <silent> <c-j> :m '>+1<cr>gv
vnoremap <silent> <c-k> :m '<-2<cr>gv

" move the line up or down by a number
let c = 1
while c <= 20
  execute "nnoremap <silent> " . c . "<c-k> :m .-" . (c+1) . "<cr>"
  execute "nnoremap <silent> " . c . "<c-j> :m .+" . c . "<cr>"
  execute "vnoremap <silent> " . c . "<c-j> :m '>+" . c . "<cr>gv"
  execute "vnoremap <silent> " . c . "<c-k> :m '<-" . (c+1) . "<cr>gv"
  let c += 1
endwhile

" open help to the right
autocmd FileType help wincmd L

" open current file in a tab
nnoremap <c-w>t :tabedit <c-r>=expand('%p')<cr><cr>

" navigate tabs
nnoremap <a-down> gt
nnoremap <a-up> gT
inoremap <a-down> <esc>gt
inoremap <a-up> <esc>gT

" move tabs left or right
nnoremap <silent> <a-s-down> :tabmove +1<cr>
nnoremap <silent> <a-s-up> :tabmove -1<cr>
tnoremap <silent> <a-s-down> <c-\><c-n>:tabmove +1<cr>
tnoremap <silent> <a-s-up> <c-\><c-n>:tabmove -1<cr>

" toggle relative number
nnoremap <leader>u :set invrelativenumber<cr>

" make ^ navigate to alternate buffer
nnoremap ^ <c-^>

" make block contents go to their own line, splitting by comma
nnoremap <silent> <leader>cs :s/\v([\[\(])/\1\r    /<cr>:s/\v([\]\)])/\r\1/<cr>k:s/\v\,\ ?/,\r    /g<cr>j0V%j

" mark just sections in the file
function! ResetToSectionMarks()
  normal m " (just avoiding trailing space by adding a comment)
  vim /\v^.?.?.?\-\-\-\ / %
  cdo normal m.
endfunction
nnoremap <leader>mm :call ResetToSectionMarks()<cr>

" load and open text from a relative github link into a buffer
nnoremap <leader>gh yiW:e <c-r>=substitute(substitute(@", "github", "raw.githubusercontent", ""), "blob/", "", "")<cr><cr>

" remove trailing whitespace
nnoremap <silent> <leader>W :%s/\v[\ \t]+$//<cr>

" change multiple occurrences of selected text easily
nnoremap c* *<c-o>cgn
nnoremap c# #<C-o>cgn

" conflict navigation and selection
" ]x moves to next conflict, [x to previous
" ]> keeps remote copy, [< keeps yours
nnoremap <silent> ]x /\v^\={7}$<cr>:noh<cr>zz
nnoremap <silent> [x ?\v^\={7}$<cr>:noh<cr>zz
nnoremap <silent> ]< $?\v^\={7}\ <cr>d/\v^\>{7}\ <cr>dd?\v^\<{7}\ <cr>dd<c-o>zz
nnoremap <silent> ]> ?\v^\<{7}\ <cr>d/\v^\={7}$<cr>dd/\v^\>{7}\ <cr>dd<c-o>zz

" diff blocks as vim text objects
nnoremap <silent> ]d /\v^diff<cr>:noh<cr>zz
nnoremap <silent> [d ?\v^diff<cr>:noh<cr>zz
nnoremap <silent> did $?\v^diff<cr>d/\v^diff<cr>:noh<cr>zz
nnoremap <silent> dad $?\v^diff<cr>d/\v^diff<cr>:noh<cr>zz

" select just pasted (or just copied, or just edited) block
" (gv already selects last visually selected block)
nnoremap gp `[v`]

nnoremap <leader>t4 :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<cr>
nnoremap <leader>t2 :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<cr>

" easy peasy window sizing. maximize buffer size
nnoremap = <c-w>=
nnoremap <a-=> <c-w>1000+<c-w>1000>
nnoremap <silent> + :set eadirection=hor equalalways noequalalways<cr><c-w>_

" format paragraph of text to fit into 80 lines (or whatever textwidth)
nnoremap + gqap

" save and close file (like git commit messages
inoremap <c-x> <esc>:x<cr>

" delete visual selection to black hole buffer, instead of replacing copy buffer
vnoremap D "_d

" show search and replace actions in a split window
if has('nvim')
  set inccommand=split
endif

" markdown folding rules
function! MarkdownLevel()
  if getline(v:lnum) =~ '^# .*$'
    return ">1"
  endif
  if getline(v:lnum) =~ '^## .*$'
    return ">2"
  endif
  if getline(v:lnum) =~ '^### .*$'
    return ">3"
  endif
  if getline(v:lnum) =~ '^#### .*$'
    return ">4"
  endif
  if getline(v:lnum) =~ '^##### .*$'
    return ">5"
  endif
  if getline(v:lnum) =~ '^###### .*$'
    return ">6"
  endif
  return "="
endfunction
au FileType markdown setlocal foldexpr=MarkdownLevel()
au FileType markdown setlocal foldmethod=expr
au FileType markdown setlocal nofoldenable

" navigation with f<tab>
au FileType markdown nnoremap <silent> f<tab> :BLines<cr>^#<space>
au FileType vim nnoremap <silent> f<tab> :BLines<cr>^"\ ---<space>
au FileType literate nnoremap <silent> f<tab> :BLines<cr>'@s<space>
au FileType literate nnoremap <silent> g<tab> :BLines<cr>^#<space>
au FileType literate nnoremap <silent> d<tab> :BLines<cr>^---\ <space>

" turn off markdown spell check
au FileType markdown setlocal nospell

" auto-save in .wiki files (vimwiki)
au CursorHold *.wiki silent update

" navigate in a comma-separated list
nnoremap <silent> gl "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr><c-o>/\w\+\_W\+<cr><c-l>:noh<cr>
nnoremap <silent> gh "_yiw?\w\+\_W\+\%#<cr>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr><c-o><c-l>:noh<cr>

" increment next number
nnoremap & <c-a>

" match and highlight keywords differently
nnoremap <silent> <leader>c1 :windo 1match Todo /\<<c-r><c-w>\>/<cr>
nnoremap <silent> <leader>c2 :windo 2match Debug /\<<c-r><c-w>\>/<cr>
nnoremap <silent> <leader>c3 :windo call matchadd("Constant", "<c-r><c-w>")<cr>
nnoremap <silent> <leader>c4 :windo call matchadd("CursorLineNr", "<c-r><c-w>")<cr>
nnoremap <silent> <leader>c5 :windo call matchadd("Macro", "<c-r><c-w>")<cr>
nnoremap <leader>C :windo call clearmatches()<cr>

" bind scroll across open windows in a tab
nnoremap <leader>sb :windo set scrollbind<cr>
nnoremap <leader>S :windo set noscrollbind<cr>

" ---- terminal commands ----
if has ('nvim')

  " enter insert mode in terminal immediately
  autocmd TermOpen * setlocal nonumber norelativenumber
  autocmd TermOpen term://* startinsert

  " open a terminal in split
  function! TermHorizontalSplit()
    exec winheight(0)/2."split" | terminal
  endfunction
  function! TermVerticalSplit()
    exec winwidth(0)/2."vsplit" | terminal
  endfunction

  nnoremap `` :tabe<cr>:terminal<cr>
  nnoremap `s :call TermHorizontalSplit()<cr>
  nnoremap `v :call TermVerticalSplit()<cr>
  nnoremap `t :tabe<cr>:terminal<cr>
  tnoremap `s <c-\><c-n>:call TermHorizontalSplit()<cr>
  tnoremap `v <c-\><c-n>:call TermVerticalSplit()<cr>
  tnoremap `t <c-\><c-n>:tabe<cr>:terminal<cr>

  " escaping from terminal
  tnoremap <leader><esc> <c-\><c-n>

  " scroll up from terminal
  tnoremap <a-s-u> <c-\><c-n><c-u>

  " copy output from last command
  tnoremap <c-y> <c-\><c-n>?<cr>0kk$vnj0"+y:noh<cr>:let @+ = '$'.@+<cr>a

  " navigation away from terminal windows
  tnoremap <s-up> <c-\><c-n><c-w>k<c-w>_
  tnoremap <s-down> <c-\><c-n><c-w>j<c-w>_
  tnoremap <s-left> <c-\><c-n><c-w>h
  tnoremap <s-right> <c-\><c-n><c-w>l
  tnoremap <a-up> <c-\><c-n>gT
  tnoremap <a-down> <c-\><c-n>gt

  autocmd BufEnter term://* normal a
endif

" ---- local extensions ----

if !empty(glob("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" ---- end ----
"
