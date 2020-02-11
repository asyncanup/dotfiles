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

" set leader key
let mapleader = ","

" ---- plugin settings ----

" deoblete init
let g:python3_host_prog = expand('~/.pyenv/versions/neovim3/bin/python')
let g:python_host_prog = expand('~/.pyenv/versions/neovim2/bin/python')
let g:deoplete#enable_at_startup = 1

" enable buffer list, with numbers
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tagbar#enabled = 1

" powerline fonts
let g:airline_powerline_fonts = 1
let g:airline_left_alt_sep = ''

" js code formatter config
let g:prettier#autoformat = 0
let g:prettier#exec_cmd_path = "~/.nvm/versions/node/v10.17.0/bin/prettier"
let g:prettier#config#tab_width = 4
nnoremap <leader>p :PrettierAsync<cr>
" autocmd BufWritePost *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" python code formatter config
autocmd BufWritePre *.py YAPF

" fullscreen zen writing mode
nnoremap <a-g> :Goyo 100<cr>

" commit finder
nnoremap gm :BCommits<cr>
nnoremap gl :Commits<cr>

" cleaner look for FZF, removes the redundant statusline that says TERMINAL
if has('nvim') && !exists('g:fzf_layout')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
endif

" allows deleting buffers en-masse
function! Bufs()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction
command! DeleteBuffers call fzf#run(fzf#wrap({
  \ 'source': Bufs(),
  \ 'sink*': { lines -> execute('bwipeout '.join(map(lines, {_, line -> split(line)[0]}))) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))
nnoremap <leader>bd :DeleteBuffers<cr>
nnoremap <a-s-x> :DeleteBuffers<cr>

" search in open buffers
nnoremap <c-f> :Lines<cr>

" search in current buffer
nnoremap <a-f> :BLines<cr>

" search in project
function RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)

nnoremap <bslash> :Rg<cr>
vnoremap <bslash> y<esc>:Rg <c-r>=escape(@",'/\')<cr><cr>

" git operations
nnoremap gb :Gblame<cr>

" show file list
let g:NERDTreeWinPos = "right"
nnoremap <leader>nt :NERDTreeFind<cr>zz50<c-w>|

" go to definition
nnoremap <space> :YcmCompleter GoTo<cr>

" go to references
nnoremap yr :YcmCompleter GoToReferences<cr>

" try to fix issue
nnoremap yx :YcmCompleter FixIt<cr>

" toggle linting
nnoremap <a-e> :ALEToggle<cr>

" git commands
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit -v<cr>

" vim screen update time is relevant for signify (git)
set updatetime=100

" git hunk jumping
nmap <a-l> <plug>(signify-next-hunk)zz
nmap <a-h> <plug>(signify-prev-hunk)zz
nnoremap <a-;> :SignifyHunkDiff<cr>
nnoremap <a-d> :SignifyDiff<cr>
nnoremap <a-u> :SignifyHunkUndo<cr>
omap ic <plug>(signify-motion-inner-pending)
xmap ic <plug>(signify-motion-inner-visual)
omap ac <plug>(signify-motion-outer-pending)
xmap ac <plug>(signify-motion-outer-visual)

" mark colors
highlight SignatureMarkText ctermfg=gray guifg=gray ctermbg=NONE guibg=NONE cterm=NONE gui=NONE

" stop rooter from changing directory automatically
let g:rooter_manual_only = 1
nnoremap <a-c> :Rooter<cr>

" startify lists
let g:startify_lists = [
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ ]

let g:startify_custom_header = ''
let g:startify_files_number = 20
let g:startify_session_persistence = 1
let g:startify_bookmarks = [ '~/.todo' ]

" vim easymotion shortcuts
nmap <leader>t <plug>(easymotion-t)
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

" show tag bar (file outline)
nnoremap <a-s-t> :TagbarToggle<cr>

" nnn file manager
nnoremap <leader>nn :NnnPicker '%:p:h'<cr>
nnoremap <leader>nc :NnnPicker<cr>
let g:nnn#layout = { 'right': '~45%' }

" " enhanced jumps
" let g:EnhancedJumps_no_mappings = 1

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
Plug 'scrooloose/nerdtree'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
Plug 'vim-scripts/CycleColor'
Plug 'flazz/vim-colorschemes'
Plug 'majutsushi/tagbar'
Plug 'plasticboy/vim-markdown'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'mcchrish/nnn.vim'
Plug 'inkarkat/vim-ingo-library' | Plug 'inkarkat/vim-EnhancedJumps'
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

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif

call plug#end()

" ---- settings that require plugins loaded ----

" file finder
command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
nnoremap <c-p> :GFiles<cr>
nnoremap <c-t> :call fzf#run({'source': 'fd', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <a-t> :call fzf#run({'source': 'fd . <c-r>=expand("%:h")<cr>', 'sink': 'e', 'window': '20new'})<cr>
nnoremap <c-o> :History<cr>
nnoremap <c-r> :History:<cr>
nnoremap <tab> :Buffers<cr>

" go to previous and next cursor locations in same buffer
map g- <plug>EnhancedJumpsLocalOlder
map g_ <plug>EnhancedJumpsLocalNewer

" color scheme
colorscheme PaperColor
set bg=dark

" signify colors (must be after color scheme)
highlight SignifySignAdd    ctermfg=magenta guifg=#00ff00 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE
highlight SignifySignDelete ctermfg=blue    guifg=#ff0000 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE
highlight SignifySignChange ctermfg=green   guifg=#ffff00 cterm=NONE gui=NONE ctermbg=NONE guibg=NONE

" line number color (overrides colorscheme)
highlight CursorLineNr ctermfg=blue

" ---- editor commands ----
" included here so that plugins can't overwrite bindings

" navigate panels (windows)
nnoremap <up> <c-w>k
nnoremap <down> <c-w>j
nnoremap <left> <c-w>h
nnoremap <right> <c-w>l
nnoremap <s-up> <c-w>k
nnoremap <s-down> <c-w>j
nnoremap <s-left> <c-w>h
nnoremap <s-right> <c-w>l
inoremap <s-up> <esc><c-w>k
inoremap <s-down> <esc><c-w>j
inoremap <s-left> <esc><c-w>h
inoremap <s-right> <esc><c-w>l

" when searching locally, reposition found location to center of screen
nnoremap n nzz
nnoremap N Nzz

" enter a line above in insert mode
inoremap <c-o> <esc>O

" crudely rename a variable
nnoremap <c-s-r> :YcmCompleter RefactorRename<space>

" bash movement shortcuts in insert mode
inoremap <c-e> <esc>A
inoremap <c-x><c-x> <esc>I
inoremap <a-b> <esc>lBi
inoremap <a-f> <esc>lWi

" go to previous and next cursor locations across buffers
nnoremap - <c-o>zz
nnoremap _ <c-i>zz

" go to previous and next edit locations in same buffer
nnoremap <a--> g;zz
nnoremap <a-_> g,zz

" use semicolon for command prompt (no shift key)
nnoremap ; :
vnoremap ; :

" quickfix shortcuts
nnoremap <a-j> :cnext<cr>
nnoremap <a-k> :cprev<cr>
nnoremap <a-o> :copen<cr>

" location list shortcuts
nnoremap <a-s-j> :lnext<cr>
nnoremap <a-s-k> :lprev<cr>
nnoremap <a-s-o> :lopen<cr>

" shortcut to save files
nnoremap <c-s> :w<cr>
nnoremap <a-s> :wa<cr>
nnoremap <a-s-s> :w!<cr>
inoremap <c-s> <esc>:w<cr>
vnoremap <c-s> <esc>:w<cr>

" easier redo
nnoremap U <c-r>

" navigate to last used buffer
nnoremap <c-6> :b#<cr>

" navigate to numbered buffer with 2o, 3o, etc
let c = 1
while c <= 99
  execute "nnoremap " . c . "o :" . c . "b\<cr>"
  let c += 1
endwhile

" unset last search highlight
nnoremap <esc> :noh<cr>:<bs>

" switch to next buffer
nnoremap L :bn<cr>
nnoremap H :bp<cr>

" reload vimrc
nnoremap <a-r> :source ~/.vimrc<cr>
inoremap <a-r> <esc>:source ~/.vimrc<cr>

" to reload a file from file system
nnoremap <leader>r :e<cr>

" join lines
nnoremap <leader>j J

" close window, quit
nnoremap <c-q> :close<cr>
nnoremap <c-a-q> :q!<cr>

" close buffer
nnoremap <c-x> :b #<cr>:bd #<cr>
nnoremap <a-x> :bp<cr>:bd #<cr>

" regular clipboard
nnoremap <c-v> "+p
nnoremap <c-y> 0"+y$:echo 'Copied: '.@+<cr>
nnoremap <a-y> gg"+yG``
inoremap <c-v> <esc>:set paste<cr>"+p:set nopaste<cr>a
vnoremap <c-y> "+y
vnoremap <c-x> "+d
vnoremap <c-v> d"+P

" open files from the same directory
nnoremap <c-e> :e <c-r>=expand("%:p:h") . "/" <cr>

" paste and nopaste
nnoremap <a-p>p :set invpaste<cr>

" install newly added plugins
nnoremap <a-p>i :w<cr>:source ~/.vimrc<cr>:PlugInstall<cr>

" cleanup removed plugins
nnoremap <a-p>c :w<cr>:source ~/.vimrc<cr>:PlugClean<cr>

" marks
nnoremap J ]`zz
nnoremap K [`zz

" use ag if available to search for text
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup
endif

" change current directory to current file's parent
nnoremap <c-c> :cd %:p:h<cr>

" save session and close
nnoremap <a-q> :SClose<cr>

" highlight cursor line
set cursorline

" make g; and g, go forward and backward for character searches
nnoremap g; ;
nnoremap g, ,

" move the line up or down
nnoremap <c-j> :m .+1<cr>==
nnoremap <c-k> :m .-2<cr>==
inoremap <c-j> <esc>:m .+1<cr>==gi
inoremap <c-k> <esc>:m .-2<cr>==gi
vnoremap <c-j> :m '>+1<cr>gv=gv
vnoremap <c-k> :m '<-2<cr>gv=gv

" open help to the right
autocmd FileType help wincmd L

" open current file in a tab
nnoremap <c-w>t :tabedit <c-r>=expand('%p')<cr><cr>

" navigate tabs
nnoremap <a-down> gt
nnoremap <a-up> gT

" toggle relative number
nnoremap <leader>u :set invrelativenumber<cr>

" make ^ navigate to alternate buffer, instead of c-^
nnoremap ^ <c-^>

" make block contents go to their own line, splitting by comma
nnoremap <leader>cs :s/\v([\[\(])/\1\r/<cr>:s/, /,\r/g<cr>:s/\v([\]\)])/\r\1/<cr>kVj%j

" mark just sections in the file
function ResetToSectionMarks()
  normal m " comment to remove trailing space
  vim /\v^...\-\-\-\ / %
  cdo normal m.
endfunction
nnoremap <leader>mm :call ResetToSectionMarks()<cr>

" load and open text from a relative github link into a buffer
nnoremap <leader>gh yiW:e <c-r>=substitute(substitute(@", "github", "raw.githubusercontent", ""), "blob/", "", "")<cr><cr>

" ---- terminal commands ----
if has ("nvim")

  " enter insert mode in terminal immediately
  if has('nvim')
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen term://* startinsert
  endif

  " open a terminal in split
  function TermHorizontalSplit()
    exec winheight(0)/2."split" | terminal
  endfunction
  function TermVerticalSplit()
    exec winwidth(0)/2."vsplit" | terminal
  endfunction
  nnoremap `s :call TermHorizontalSplit()<cr>
  nnoremap `v :call TermVerticalSplit()<cr>
  nnoremap `t :terminal<cr>

  " escaping from terminal
  tnoremap <leader><esc> <c-\><c-n>

  " copy output from last command
  tnoremap <c-y> <c-\><c-n>?<cr>0kk$vnj0"+y:noh<cr>:let @+ = '$'.@+<cr>a

  " faster exit from terminal and close window
  tnoremap <c-q> <c-\><c-n>:b #<cr>

  " navigation away from terminal windows
  tnoremap <s-up> <c-\><c-n><c-w>k
  tnoremap <s-down> <c-\><c-n><c-w>j
  tnoremap <s-left> <c-\><c-n><c-w>h
  tnoremap <s-right> <c-\><c-n><c-w>l

  autocmd BufEnter term://* normal a
endif

" ---- local extensions ----

if !empty(glob("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" ---- end ----
"
