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
set switchbuf=usetab,vsplit

" vim screen update time is relevant for signify (git)
set updatetime=100

" highlight cursor line
set cursorline

" set leader key
let mapleader = ","

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
let g:prettier#exec_cmd_path = "~/.nvm/versions/node/v10.17.0/bin/prettier"
let g:prettier#config#tab_width = 4
nnoremap <silent> <leader>p :PrettierAsync<cr>
" autocmd BufWritePost *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" python code formatter config
" autocmd BufWritePre *.py YAPF

" fullscreen zen writing mode
nnoremap <silent> <a-g> :Goyo 100<cr>

" commit finder
nnoremap <silent> gm :BCommits<cr>
nnoremap <silent> gl :Commits<cr>

" cleaner look for FZF, removes the redundant statusline that says TERMINAL
if has('nvim') && !exists('g:fzf_layout')
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

" search in project
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -g "!yarn.lock" -g "!package-lock.json" %s || true'
  let query_filtered = a:query
  let file_filter = ''
  let query_parts = split(a:query)
  if index(query_parts, '-g') == 0
    let query_filtered = join(query_parts[2:])
    let file_filter = '-g "'.query_parts[1].'" '
  endif
  let initial_command = printf(command_fmt, file_filter.shellescape(query_filtered))
  let reload_command = printf(command_fmt, file_filter.'{q}')
  let spec = {'options': ['--query', query_filtered, '--bind', 'change:reload:'.reload_command.',alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up']}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang Ripgrep call RipgrepFzf(<q-args>, <bang>0)

nnoremap <silent> <bslash> :Rg<cr>
nnoremap <silent> \| :Rg <c-r>=expand('<cword>')<cr><cr>
vnoremap <silent> <bslash> y<esc>:Rg <c-r>=escape(@",'\{(')<cr><cr>

" search for personal notes
nnoremap <silent> gn :Rg :note:<cr>

" git operations
nnoremap gb :Gblame<cr>

" go to definition
nnoremap <enter> :YcmCompleter GoTo<cr>zt

" go to references
nnoremap <silent> yr :YcmCompleter GoToReferences<cr>:cnext<cr>:cprev<cr>

" try to fix issue
nnoremap yx :YcmCompleter FixIt<cr>

" restart type server
nnoremap <leader>yr :YcmRestartServer<cr>

" YouCompleteMe code formatter
nnoremap <leader>yf :YcmCompleter Format<cr>

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

" vim easymotion shortcuts
xmap <leader>t <plug>(easymotion-t)
omap <leader>t <plug>(easymotion-t)

nmap <leader>f <plug>(easymotion-overwin-f)
xmap <leader>f <plug>(easymotion-bd-f)
omap <leader>f <plug>(easymotion-bd-f)

nmap <leader>l <plug>(easymotion-overwin-line)
xmap <leader>l <plug>(easymotion-bd-jk)
omap <leader>l <plug>(easymotion-bd-jk)

nmap <leader>s <plug>(easymotion-overwin-f2)
xmap <leader>s <plug>(easymotion-bd-f2)
omap <leader>s <plug>(easymotion-bd-f2)

" cycle through color schemes
nnoremap <leader>cn :CycleColorNext<cr>
nnoremap <leader>cp :CycleColorPrev<cr>

" show Vista file outline
nnoremap <a-s-t> :Vista!!<cr><c-w>15>

" nnn file manager
nnoremap <silent> <leader><tab> :NnnPicker '%:p:h'<cr>
let g:nnn#layout = { 'down': '~35%' }
let g:nnn#action = {
      \ '<c-t>': 'tab split',
      \ '<c-x>': 'split',
      \ '<c-v>': 'vsplit' }

" disable vim features on large files
let g:LargeFile = 10

" enhanced jumps
let g:EnhancedJumps_no_mappings = 1

" ultisnips
let g:UltiSnipsExpandTrigger = '<c-t>'
let g:UltiSnipsJumpForwardTrigger = '<c-x>'

" ctrl-space window, tab, workspace management
let g:CtrlSpaceDefaultMappingKey = '<space> '
let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
let g:CtrlSpaceSaveWorkspaceOnExit = 1
nnoremap <a-s-w> :CtrlSpaceSaveWorkspace<cr>

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
Plug 'easymotion/vim-easymotion'
Plug 'flazz/vim-colorschemes'
Plug 'plasticboy/vim-markdown'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'mcchrish/nnn.vim'
Plug 'vim-scripts/LargeFile'
Plug 'pgr0ss/vim-github-url'
Plug 'nelstrom/vim-visual-star-search'
Plug 'liuchengxu/vista.vim'
Plug 'vim-ctrlspace/vim-ctrlspace'
" ---- place to add new plugins ----

Plug 'w0rp/ale', { 'on': 'ALEToggle' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --all' }
Plug 'prettier/vim-prettier', { 'for': ['javascript', 'typescript', 'css', 'json', 'markdown', 'yaml', 'html'] }
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }

if has('nvim') || has('patch-8.0.902')
  Plug 'kshenoy/vim-signature'
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

call plug#end()

" ---- settings that require plugins loaded ----

" go to previous and next cursor locations in same buffer
map g- <plug>EnhancedJumpsLocalOlder
map g_ <plug>EnhancedJumpsLocalNewer

" file finder
command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
nnoremap <silent> <c-p> :GFiles<cr>
nnoremap <silent> <a-t> :call fzf#run({'source': 'fd -H --no-ignore-vcs', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <silent> <c-t> :call fzf#run({'source': 'fd -H --no-ignore-vcs . <c-r>=expand("%:h")<cr>', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <silent> <c-o> :History<cr>
nnoremap <silent> <tab> :Buffers<cr>

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
endfunction
autocmd User AirlineAfterTheme call s:update_colors()

" color scheme
colorscheme PaperColor
set bg=dark

" ---- editor commands ----
" included here so that plugins can't overwrite bindings

" move to first character of line
nnoremap g0 g^

" open a new empty tab
nnoremap <leader>tt :tabe<cr>

" navigate panels (windows)
nnoremap <up> <c-w>k
nnoremap <down> <c-w>j
nnoremap <left> <c-w>h
nnoremap <right> <c-w>l

nnoremap <s-up> <c-w>k<c-w>_
nnoremap <s-down> <c-w>j<c-w>_
nnoremap <s-left> <c-w>=<c-w>h
nnoremap <s-right> <c-w>=<c-w>l

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

  execute "inoremap " . c . "<s-up> " . c . "<esc><c-w>k<c-w>_"
  execute "inoremap " . c . "<s-down> " . c . "<esc><c-w>j<c-w>_"
  execute "inoremap " . c . "<s-left> " . c . "<esc><c-w>h"
  execute "inoremap " . c . "<s-right> " . c . "<esc><c-w>l"

  let c += 1
endwhile

" when searching locally, reposition found location to center of screen
nnoremap n n
nnoremap N N

" enter a line above in insert mode
inoremap <c-o> <esc>O

" crudely rename a variable
nnoremap <c-r> :YcmCompleter RefactorRename<space>

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
nnoremap <silent> <a-s-j> :lnext<cr>
nnoremap <silent> <a-s-k> :lprev<cr>
nnoremap <a-s-o> :lopen<cr>

" shortcut to save files
nnoremap <c-s> :w<cr>
nnoremap <a-s> :wa<cr>
nnoremap <a-s-s> :w!<cr>
inoremap <c-s> <esc>:w<cr>
vnoremap <c-s> <esc>:w<cr>

" easier redo
nnoremap U <c-r>

" unset last search highlight
nnoremap <esc> :noh<cr>:<bs>

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

" regular clipboard
nnoremap <c-v> "+p
nnoremap <c-y> 0"+y$:echo 'Copied: '.@+<cr>
nnoremap <a-y> gg"+yG``
inoremap <silent> <c-v> <esc>:set paste<cr>"+p:set nopaste<cr>a
vnoremap <c-y> "+y
vnoremap <c-x> "+d
vnoremap <c-v> d"+P

" open files from the same directory
nnoremap <c-e> :edit <c-r>=expand("%:p:h") . "/" <cr>
nnoremap <a-e> :split <c-r>=expand("%:p:h") . "/" <cr>
nnoremap <a-s-e> :tabedit <c-r>=expand("%:p:h") . "/" <cr>

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
inoremap <silent> <c-j> <esc>:m .+1<cr>gi
inoremap <silent> <c-k> <esc>:m .-2<cr>gi
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

" make ^ navigate to alternate buffer, instead of c-^
nnoremap ^ <c-^>

" make block contents go to their own line, splitting by comma
nnoremap <silent> <leader>cs :s/\v([\[\(])/\1\r    /<cr>:s/\v([\]\)])/\r\1/<cr>k:s/\v\,\ ?/,\r    /g<cr>j0V%j

" mark just sections in the file
function! ResetToSectionMarks()
  normal m " (just avoiding trailing space by adding a comment)
  vim /\v^...\-\-\-\ / %
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
nnoremap + :set eadirection=hor equalalways noequalalways<cr><c-w>_

" save and close file (like git commit messages
inoremap <c-x> <esc>:x<cr>

" delete visual selection to black hole buffer, instead of replacing copy buffer
vnoremap D "_d

" ---- terminal commands ----
if has ("nvim")

  " enter insert mode in terminal immediately
  if has('nvim')
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen term://* startinsert
  endif

  " open a terminal in split
  function! TermHorizontalSplit()
    exec winheight(0)/2."split" | terminal
  endfunction
  function! TermVerticalSplit()
    exec winwidth(0)/2."vsplit" | terminal
  endfunction
  nnoremap `` :terminal<cr>
  nnoremap `s :call TermHorizontalSplit()<cr>
  nnoremap `v :call TermVerticalSplit()<cr>
  nnoremap `t :tabe<cr>:terminal<cr>
  tnoremap `s <c-\><c-n>:call TermHorizontalSplit()<cr>
  tnoremap `v <c-\><c-n>:call TermVerticalSplit()<cr>
  tnoremap `t <c-\><c-n>:tabe<cr>:terminal<cr>

  " escaping from terminal
  tnoremap <leader><esc> <c-\><c-n>

  " scroll up from terminal
  tnoremap <c-u> <c-\><c-n><c-u>

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
