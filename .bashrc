# ---- default bashrc ----

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ---- custom ----

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# fzf bash completion and key bindings
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# z directory auto jump
[ -f ~/.z.bash ] && source ~/.z.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# powerline shell
_update_ps1() {
  PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PATH="~/.pyenv/bin:$PATH"
command -v pyenv &> /dev/null && eval "$(pyenv init -)"
command -v pyenv &> /dev/null && eval "$(pyenv virtualenv-init -)"

# go
export GOROOT=/usr/local/go
export GOPATH=$HOME/src
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# ---- save history across terminals ----
HISTSIZE=10000
HISTFILESIZE=50000
HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

export PATH="$PATH:~/bin:~/.local/bin:~/bin/node_modules/.bin"

# ---- pyenv controls python when this line is commented ----
#export PATH="/usr/bin:/usr/local/bin:$PATH"

# ---- colors ----
BLACK='\e[0;30m'
DARKGRAY='\e[1;30m'
RED='\e[0;31m'
LIGHTRED='\e[1;31m'
GREEN='\e[0;32m'
LIGHTGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
BLUE='\e[0;34m'
LIGHTBLUE='\e[1;34m'
PURPLE='\e[0;35m'
LIGHTPURPLE='\e[1;35m'
CYAN='\e[0;36m'
LIGHTCYAN='\e[1;36m'
LIGHTGRAY='\e[0;37m'
WHITE='\e[1;37m'
RESET='\e[0m'

BG_BLUE='\e[48;5;24m'
BG_DARKGRAY='\e[48;5;237m'
BG_GRAY='\e[48;5;238m'
BG_GREEN='\e[48;5;22m'
BG_ORANGE='\e[48;5;130m'
FG_BLUE='\e[38;5;24m'
FG_DARKGRAY='\e[38;5;237m'
FG_GRAY='\e[38;5;238m'
FG_GREEN='\e[38;5;22m'
FG_LIGHTGRAY='\e[38;5;250m'
FG_ORANGE='\e[38;5;130m'
FG_WHITE='\e[38;5;15m'

# ---- git shortcuts ----
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

glog() {
  is_in_git_repo || return
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $1 | \
   fzf --height 75% --ansi --no-sort --reverse --tiebreak=index --preview \
   'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
   --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up,ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF" --preview-window=right:60%
}

git-files() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf --height 90% -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; bat --color always {-1})' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -c4- | sed 's/.* -> //'
}

git-branches() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 50% --ansi --multi --tac \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

git-tags() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf --height 50% --multi \
    --preview 'git show --color=always {} | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70%
}

git-commit-hashes() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf --height 50% --ansi --no-sort --reverse --multi \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:40% |
  grep -o "[a-f0-9]\{7,\}"
}

git-remotes() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf --height 50% --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -d$'\t' -f1
}

alias gcd='cd $(git rev-parse --show-toplevel)'
gcf() {
  files="$(git-files)"
  if [[ $files != '' ]]; then
    git add $files
    git commit --verbose
  fi
}
gdbr() {
  git diff $1..HEAD
}
alias gdm='git diff $(git merge-base master HEAD)..HEAD'
alias gcof='git checkout $(git branch | fzf)'
alias gaf='git add $(git-files)'
alias ghist='git log $(git merge-base master HEAD)..HEAD --pretty=format:"%B"'

alias g='git'
complete -F _complete_alias g

alias gs='g s'
alias gcl='g cl'
alias gd='g d'
alias gdc='g dc'
alias gdi='g di'
alias gsh='g sh'
alias gco='g co'
alias gcob='g cob'
alias ga='g a'
alias gap='g ap'
alias gst='g st'
alias gstl='g stl'
alias gstp='g stp'
alias gsts='g sts'
alias gstc='g stc'
alias gc='g c'
alias gcm='g cm'
alias gcam='g cam'
alias gcc='g cc'
alias gca='g ca'
alias gb='g b'
alias gbd='g bd'
alias gbD='g bD'
alias gl='g l'
alias gr='g r'
alias grs='g rs'
alias grh='g rh'
alias grsh='g rsh'
alias grhh='g rhh'
alias grp='g rp'
alias grev='g rev'
alias gcat='g cat'
alias gpl='g pl'
alias gpom='g pom'
alias gtype='g type'
alias gm='g m'
alias gmf='g mf'
alias gri='g ri'
alias grim='g rim'
alias gra='g ra'
alias grc='g rc'
gp() {
  g p $@
}

# primary git interface
gg() {
  if ! git status >/dev/null 2>&1; then
    echo "Not a git repository"
    return 1
  fi

  time="$(date +%H:%M:%S)"
  branch="$(git rev-parse --abbrev-ref HEAD)"
  commit_hash="$(git rev-parse --short HEAD)"
  dir="$(pwd | sed s,$HOME,~,)"

  # when in the middle of a rebase, or other multi-step operations
  if [[ "$branch" == "HEAD" ]]; then
    branch_bg="$BG_ORANGE"
    branch_fg="$FG_ORANGE"
  else
    branch_bg="$BG_BLUE"
    branch_fg="$FG_BLUE"
  fi

  echo -e \
    "${BG_GRAY}${FG_LIGHTGRAY} $time"\
    "${branch_bg}${FG_GRAY}${FG_WHITE} $branch"\
    "${BG_GREEN}${branch_fg}${FG_WHITE} $commit_hash"\
    "${BG_DARKGRAY}${FG_GREEN}${FG_LIGHTGRAY} $dir"\
    "${RESET}${FG_DARKGRAY}${RESET}"

  echo
  git status -s
  echo

  help=""
  help+="${CYAN}a${BLUE}dd,   "
  help+="${CYAN}d${BLUE}iff,  "
  help+="add pa${CYAN}t${BLUE}ch,   "
  help+="added d${CYAN}i${BLUE}ff,        "
  help+="stashed di${CYAN}f${BLUE}f,      "
  help+="commit histor${CYAN}y${BLUE},    "

  help+="\n"

  help+="sh${CYAN}o${BLUE}w,  "
  help+="${CYAN}l${BLUE}og,   "
  help+="${CYAN}b${BLUE}ranch,      "
  help+="p${CYAN}u${BLUE}ll,              "
  help+="${CYAN}c${BLUE}ommit,            "
  help+="${CYAN}p${BLUE}ush,              "

  help+="\n"

  help+="${CYAN}s${BLUE}tash, "
  help+="${CYAN}r${BLUE}eset, "
  help+="reset ${CYAN}h${BLUE}ard,  "
  help+="stash ${CYAN}j${BLUE}ust patch,  "
  help+="patch ${CYAN}w${BLUE}ith stash,  "
  help+="rebase to ${CYAN}m${BLUE}aster${RESET}\n"

  printf "$help"

  read -p ":" -n1 key
  echo
  case $key in
    $'\e'|q)    return 0 ;;
    a)          git add $(git-files) ;;
    d)          git diff ;;
    t)          git add $(git-files) -p ;;
    i)          git diff --cached ;;
    f)          git stash show -p ;;
    y)          ghist ;;

    o)          git show ;;
    l)          glog ;;
    b)          git checkout $(git-branches) ;;
    u)          git pull ;;
    c)          git commit --verbose ;;
    p)          gp ;;

    s)          git stash ;;
    r)          git reset ;;
    h)          git reset --hard HEAD ;;
    j)          git stash -p ;;
    w)          git stash pop ;;
    m)          git rebase -i master ;;

    $';')       read -e -p "$ " cmd; bash -lic "$cmd" ;;
    *)          ;;
  esac
  gg
}

bind '"\er": redraw-current-line'
bind '"\C-g\C-f": "$(git-files)\e\C-e\er"'
bind '"\C-g\C-b": "$(git-branches)\e\C-e\er"'
bind '"\C-g\C-t": "$(git-tags)\e\C-e\er"'
bind '"\C-g\C-h": "$(git-commit-hashes)\e\C-e\er"'
bind '"\C-g\C-r": "$(git-remotes)\e\C-e\er"'

# ---- other aliases ----
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="bat --paging always"
export MANPAGER=most

shopt -s nocaseglob

alias less='less -K'
alias rmf='rm -rf'
alias cl='clear'

alias b='bazel'
complete -F _complete_alias b
alias bb='bazel build'
alias bbv='bazel build --verbose_failures --sandbox_debug'
alias br='bazel run'
alias brv='bazel run'
alias bq='bazel query'
alias bc='bazel clean'
alias bce='bazel clean --expunge'
alias bqb='bazel query --output=build'
alias bqr='bazel query --output=run'
alias bf='bazel fetch'

alias j='jira'
complete -F _complete_alias j
alias ji='jira issue'
alias jj='jira issue | grep In.Progress'

alias sb='. ~/.bashrc'
alias sbl='. ~/.bashrc.local'
alias seb='nvim ~/.bashrc && . ~/.bashrc'
alias sebl='nvim ~/.bashrc.local && . ~/.bashrc'

alias c='xclip -selection clipboard'
alias v='xclip -selection cliboard -o'

alias apt='sudo apt-get install'
alias aptremove='sudo apt-get remove'
alias aptupdate='sudo apt-get update'

alias ..='cd ..'

# FZF fuzzy finder settings
export FZF_DEFAULT_COMMAND='rg --hidden'
export FZF_DEFAULT_OPTS='--no-info --height 50% --reverse'
export FZF_CTRL_T_COMMAND='rg --hidden --files'
export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always {}" --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up"'
complete -F _fzf_dir_completion -o default -o bashdefault tree

alias d='docker'
alias db='docker build .'
alias dps='docker ps'
alias di='docker images'
complete -F _complete_alias d

alias e='nvim'
complete -F _complete_alias e

alias psa='ps -a | grep'
alias kk='kill -9'
alias jl='jobs -l'
alias killjobs="kill -9 $(jobs -p)"
alias k='kill'
complete -F _complete_alias k

# todo tools
alias t='echo "$(date +%H:%M)" >> ~/.todo'
alias t-newday="echo $'\n'$(date +%Y-%m-%d)$'\n' >> ~/.todo"
alias t-edit='nvim ~/.todo'
alias t-entry='echo >> ~/.todo'
alias t-tail='tail ~/.todo'
alias tt='t-tail'
alias t-amend='LAST_TIME=$(tail -1 ~/.todo | sed -n '\''s/^\([0-9]*:[0-9]*\) .*/\1/p'\'') && [[ ! -z "$LAST_TIME" ]] && tmpfile=$(mktemp) && head -n -1 ~/.todo > $tmpfile && cat $tmpfile > ~/.todo && rm $tmpfile && echo "$LAST_TIME" >> ~/.todo'

# nnn file manager
n() {
    # Block nesting of nnn in subshells
    if [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef
    nnn -c "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}
export NNN_PLUG='x:_chmod +x $nnn;g:_git status;o:fzopen;t:_tree $nnn;c:_/home/abishnoi/bin/copyfilepath $nnn'
export NNN_CONTEXT_COLORS='4123'
export NNN_TRASH=1

alias nb='npm run build'
alias ns='npm start'
alias nr='npm run'

alias pv='python --version'
alias nv='node -v'

# asciinema shell recordings
alias rec='asciinema rec -i 1 .shell-recordings/`date +%Y-%m-%d`.cast'
alias recplay='asciinema play -i 0.1'

# yadm dotfiles manager
yadm-git-files() {
  yadm -c color.status=always status --short |
  fzf --height 90% -m --ansi --nth 2..,.. \
    --preview '(yadm diff --color=always -- {-1} | sed 1,4d; bat --color always {-1})' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -c4- | sed 's/.* -> //'
}
alias ycf='yadm add $(yadm-git-files); yadm commit --verbose'

alias ya='yadm add'
alias yd='yadm diff'
alias yds='yadm diff --stat'
alias yl='yadm list'
alias yc='yadm commit --verbose'
alias yca='yadm commit -a --verbose'
alias ys='yadm status'
alias yp='yadm push'
alias ypl='yadm pull'

# searching and opening web links
s() {
  lynx https://duckduckgo.com/?q="$*"
}
alias l="lynx"

# lynx config location
export LYNX_CFG=~/.config/lynx/lynx.cfg
export LYNX_LSS=~/.config/lynx/lynx.lss

# replacing rm with trash-cli
alias trash='~/.pyenv/versions/3.7.0/bin/trash-put'
alias rm='\rm'

# select directors with fzf
list-dirs() {
  fd ${1:-.} -t d |
  fzf --height 50% --multi --ansi
}
bind '"\C-f\C-d": "$(list-dirs)\e\C-e\er"'

list-all-dirs() {
  fd -I ${1:-.} -t d |
  fzf --height 50% --multi --ansi
}
bind '"\C-f\C-e": "$(list-all-dirs)\e\C-e\er"'

# fd shortcuts
alias fdh='fd --hidden'
alias fdi='fd --no-ignore'
alias fdih='fd --hidden --no-ignore'
alias fdid='fd --no-ignore --type d'

alias diff='git diff --no-index'

# watch files
watchfile() {
  while inotifywait -e modify -e close_write $1 2>/dev/null; do
    $1 2>&1 | bat -l ${2:-python}
  done
}

# ---- load local customization file ----
[ -s "$HOME/.bashrc.local" ] && \. "$HOME/.bashrc.local"

# ---- end ----

