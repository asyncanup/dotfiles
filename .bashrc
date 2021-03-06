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

# make directory and change to it, at the same time
mkcd() {
  mkdir -p $1
  cd $1
}

# ---- colors ----
C_BLACK='\e[0;30m'
C_DARKGRAY='\e[1;30m'
C_RED='\e[0;31m'
C_LIGHTRED='\e[1;31m'
C_GREEN='\e[0;32m'
C_LIGHTGREEN='\e[1;32m'
C_ORANGE='\e[0;33m'
C_YELLOW='\e[1;33m'
C_BLUE='\e[0;34m'
C_LIGHTBLUE='\e[1;34m'
C_PURPLE='\e[0;35m'
C_LIGHTPURPLE='\e[1;35m'
C_CYAN='\e[0;36m'
C_LIGHTCYAN='\e[1;36m'
C_LIGHTGRAY='\e[0;37m'
C_WHITE='\e[1;37m'
C_RESET='\e[0m'

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

cecho() {
  color=\$${1:-RESET}
  echo -ne "$(eval echo ${color})"
  cat
  echo -ne "${RESET}"
}

# ---- keys ----
capture-keypress() {
  read -s -n1
  K1="$REPLY"
  read -s -n2 -t 0.001
  K2="$REPLY"
  read -s -n1 -t 0.001
  K3="$REPLY"
  echo "$K1$K2$K3"
}

KEY_INSERT=$'\x1b\x5b\x32\x7e'
KEY_DELETE=$'\x1b\x5b\x33\x7e'
KEY_HOME=$'\x1b\x4f\x48'
KEY_END=$'\x1b\x4f\x46'
KEY_PAGEUP=$'\x1b\x5b\x35\x7e'
KEY_PAGEDOWN=$'\x1b\x5b\x36\x7e'
KEY_UP=$'\x1b\x5b\x41'
KEY_DOWN=$'\x1b\x5b\x42'
KEY_RIGHT=$'\x1b\x5b\x43'
KEY_LEFT=$'\x1b\x5b\x44'
KEY_TAB=$'\x09'
KEY_ENTER=$'\x0a'
KEY_ESCAPE=$'\x1b'
KEY_SPACE=$'\x20'

# ---- common regular expressions ----

RE_EXT='[a-z][a-z][a-z]?[a-z]?'
RE_NAME='[^\/]+'
RE_FILENAME="$RE_NAME\.$RE_EXT"


# ---- custom ----

# add base PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# add custom scripts/dependencies to PATH
export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

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

# ability to do bash completion on aliases
[ -f ~/.bash_completions/alias_bash_completion ] && \
  source ~/.bash_completions/alias_bash_completion

# fzf bash completion and key bindings
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fzf tab completion
[ -f ~/bin/fzf-bash-completion.sh ] && source ~/bin/fzf-bash-completion.sh
_fzf_bash_completion_loading_msg() { echo "${PS1@P}${READLINE_LINE}" | tail -n1; }
FZF_COMPLETION_OPTS='-m'

if [ "$(uname)" != "Darwin" ]; then
  bind -x '"\t": fzf_bash_completion'
fi

# z directory auto jump
[ -f ~/.z.bash ] && source ~/.z.bash

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# yarn
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"

# pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PATH="$PATH:$HOME/.pyenv/bin"

if [ "$(uname)" == "Darwin" ]; then
  export PYTHON_CONFIGURE_OPTS="--enable-framework"
fi

command -v pyenv > /dev/null && eval "$(pyenv init -)"
command -v pyenv > /dev/null && eval "$(pyenv virtualenv-init -)"

# pyenv controls python when this line is commented
#export PATH="/usr/bin:/usr/local/bin:$PATH"

# rbenv
export PATH="$PATH:$HOME/.rbenv/bin"
command -v rbenv > /dev/null && eval "$(rbenv init -)"

# go
export GOROOT=/usr/local/go
export GOPATH=$HOME/src
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

# rust
export PATH="$PATH:$HOME/.cargo/bin"

# add locally installed node_modules binaries from a project to PATH
export PATH="$PATH:./node_modules/.bin"

# dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# save history across terminals
HISTSIZE=10000
HISTFILESIZE=50000
HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT="%Y-%m-%d · "
if [[ ! $PROMPT_COMMAND =~ "history -a" ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
fi

# powerline shell
update-ps1() {
  PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ update-ps1 ]]; then
  # update-ps1 should be the first command in PROMPT_COMMAND because it tries to
  # capture exit code from the last user-run command
  PROMPT_COMMAND="update-ps1; $PROMPT_COMMAND"
fi

# time every command run in the shell:
# remember the time when timer_start is first run, or since timer_stop was run
timer_start() {
  export __timer=${__timer:-$SECONDS}
  if [[ $__start_date == "" ]]; then
    export __start_date="$(date +'%m/%d %H:%M:%S')"
  fi
}

# calculate time elapsed since the first time timer_start was run before this
timer_stop() {
  export __timer_show="$(($SECONDS - $__timer))s"
}
timer_unset() {
  unset __timer
  unset __start_date
}
export __timer_show=""

# add timer_stop to PROMPT_COMMAND only if it's not already there
if [[ ! $PROMPT_COMMAND =~ timer_stop ]]; then
  # stop timer needs to run before powerline updates PS1, so that the time value
  # shows up in powerline prompt
  #
  # reset timer needs to happen at the end of PROMPT_COMMAND so that the very
  # next user-run command starts the timer
  PROMPT_COMMAND="timer_stop; $PROMPT_COMMAND; timer_unset;"
fi

# run timer_start before EVERYTHING that runs in bash
trap 'timer_start' DEBUG

# remember last command's exit code if it was an error
# powerline uses it to show it in the prompt
capture_exit_code() {
  exit_code=$?
  if [[ $exit_code != 0 ]]; then
    export __exit_error_code="❌ $exit_code"
  else
    export __exit_error_code="✔️"
  fi
  unset exit_code
}
if [[ ! $PROMPT_COMMAND =~ capture_exit_code ]]; then
  PROMPT_COMMAND="capture_exit_code; $PROMPT_COMMAND"
fi

# when you need the current elapsed time in front of shell output log
ts() {
  local PAD=$(printf '%*s' "$COLUMNS")
  local START=$SECONDS
  "$@" 2>&1 | while IFS= read -r line; do
    local DIFF=$(( $SECONDS - $START ))
    START=$SECONDS
    printf '%s' "$line"
    if [[ $DIFF != 0 ]]; then
      printf "${C_DARKGRAY}"
      printf '%*.*s' 0 $(( COLUMNS - (${#line} % COLUMNS) - ${#DIFF} - 3 )) "$PAD"
      printf "${DIFF}s"
      printf "${C_RESET}"
    fi
    printf "\n"
  done
}

# ---- npm package versions for a given list of folder paths ----
package-json-versions() {
  xargs -I % bash -c 'echo $(jq .version %/package.json) %'
}

# ---- git shortcuts ----

# git bash completion
[ -f ~/.bash_completions/git_bash_completion ] && \
  source ~/.bash_completions/git_bash_completion

# helpful functions, for defining keyboard shortcuts and otherwise
is-in-git-repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

glog() {
  is-in-git-repo || return
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" -1000 $1 | \
   fzf --height 75% --ansi --no-sort --reverse --tiebreak=index --preview \
   'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{9\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
   --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up,ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF" --preview-window=right:60%
}

git-ls-files() {
  is-in-git-repo || return
  git ls-files |
  fzf --height 90% -m --ansi --nth 2..,.. \
    --preview 'bat --style=numbers,header --color=always {}' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -c4- | sed 's/.* -> //'
}

git-files() {
  is-in-git-repo || return
  git -c color.status=always status --short |
  fzf --height 90% -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; bat --style full --color always '{-1}')' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -c4- | sed 's/.* -> //'
}

git-branches() {
  is-in-git-repo || return
  git branch --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 50% --ansi --multi --tac \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

git-tags() {
  is-in-git-repo || return
  git tag --sort -version:refname |
  fzf --height 50% --multi \
    --preview 'git show --color=always {} | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70%
}

git-commit-hashes() {
  is-in-git-repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf --height 50% --ansi --no-sort --reverse --multi \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:40% |
  grep -o "[a-f0-9]\{7,\}"
}

git-remotes() {
  is-in-git-repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf --height 50% --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -d$'\t' -f1
}

# base shortcuts
alias g='git'
if [ "$(uname)" != "Darwin" ]; then
  complete -F _complete_alias g
fi

gco() {
  git checkout $(git-branches)
}

gcf() {
  files="$(git-files)"
  if [[ $files != '' ]]; then
    git add $files
    git commit --verbose
  fi
}

gp() {
  g p $@
}

grbc() {
  git add $(git-files);
  if [[ "$(git diff --cached)" == "" ]]; then
    git rebase --skip
  else
    git rebase --continue
  fi
}

gmerge_to_master() (
  set -ex
  br=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$br" == "master" ]]; then
    echo "Already on master"
  fi
  git checkout master
  git pull --rebase
  git merge $br
  git push
  git branch --delete $br
  git push -d origin $br
)

function gdeletemerged() {
  branches_to_delete=$(git branch -r --merged origin/master | grep -v origin/master | sed "s/.*\///")
  for branch_name in $branches_to_delete
  do
    git branch -d $branch_name
    rm .git/refs/remotes/origin/$branch_name
    git push -d origin $branch_name
  done
}
alias gcd='cd $(git rev-parse --show-toplevel)'

# primary git interface
gg() {
  if ! git status >/dev/null 2>&1; then
    echo "Not a git repository"
    return 1
  fi

  local time="$(date +%H:%M:%S)"
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  local commit_hash="$(git rev-parse --short HEAD)"
  local dir="$(pwd | sed s,$HOME,~,)"

  local branch_bg
  local branch_fg
  # when in the middle of a rebase, or other multi-step operations
  if [[ "$branch" == "HEAD" ]]; then
    branch_bg="$BG_ORANGE"
    branch_fg="$FG_ORANGE"
  else
    branch_bg="$BG_BLUE"
    branch_fg="$FG_BLUE"
  fi

  echo -e \
    "\n${BG_GRAY}${FG_LIGHTGRAY} $time"\
    "${branch_bg}${FG_GRAY}${FG_WHITE} $branch"\
    "${BG_GREEN}${branch_fg}${FG_WHITE} $commit_hash"\
    "${BG_DARKGRAY}${FG_GREEN}${FG_LIGHTGRAY} $dir"\
    "${C_RESET}${FG_DARKGRAY}${C_RESET}"

  echo
  git status -s
  echo

  local H="${C_CYAN}"
  local B="${C_BLUE}"
  printf " ${H}b${B}ranch"          # branch
  printf "  ${H}l${B}og"            # log
  printf "  ${H}d${B}iff"           # diff
  printf "  ${H}c${B}ommit"         # new commit
  printf "  ${H}D${B}iff o/master"  # diff origin/master
  printf "  r${H}e${B}base  "       # rebase
  printf "  ${H}f${B}etch"          # fetch
  printf "  ${H}p${B}ush\n"         # rebase & push

  printf " ${H}s${B}tash "          # stash
  printf "  p${H}o${B}p"            # stash pop
  printf "  ${H}a${B}dd "           # add
  printf "  a${H}m${B}end "         # amend commit
  printf "  ${H}u${B}pdate master"  # update master
  printf "  co${H}n${B}tinue"       # continue rebase
  printf "  ${H}r${B}eset"          # reset
  printf "  ${H}R${B}ESET\n"        # reset hard

  while true; do
    echo -en "\r$(tput el)${C_CYAN}${C_RESET} "

    read -s -n1
    local K1="$REPLY"
    read -s -n1 -t 0.2
    local K2="$REPLY"
    read -s -n2 -t 0.001
    local K3="$REPLY"
    local pressed_key="$K1$K2$K3"
    if [[ "$pressed_key" =~ [a-z][a-z] ]]; then
      echo -n 'use semicolon (;) for typing long commands'
      read -s -e -t 2
      continue
    fi

    local c_head=$(git merge-base HEAD master)
    local c_master=$(git rev-parse master)
    case $pressed_key in
      b)    echo branch; gco ;;
      l)    echo log; glog ;;
      d)    echo diff; git diff ;;
      c)    echo commit; git add $(git-files); git commit --verbose ;;
      D)    echo diff master; git diff origin/master..HEAD ;;
      e)    echo rebase; git rebase -i $(git-branches) ;;
      f)    echo fetch; git fetch ;;
      p)    echo push; [[ $c_head != $c_master ]] && git rebase -i origin/master; gp ;;

      s)    echo stash; git stash ;;
      o)    echo pop; git stash pop ;;
      a)    echo add; git add $(git-files) ;;
      m)    echo amend commit; git add $(git-files); git commit --amend --verbose ;;
      u)    echo update master; git checkout master; git pull --rebase; git checkout - ;;
      n)    echo rebase continue; grbc ;;
      r)    echo reset soft; git reset ;;
      R)    echo reset hard; git reset --hard HEAD ;;

      $';') echo shell; read -e -p "$ " cmd; bash -lic "$cmd" ;;
      g)    read -e -p "git " cmd; [[ "$cmd" != "" ]] && bash -lic "git $cmd" ;;

      $KEY_ESCAPE|\
      q)     echo quit; return 0 ;;
      $KEY_SPACE)  echo refresh; break ;;
      *)     continue ;;
    esac
    break
  done

  gg
}

# git keyboard shortcuts

bind '"\C-f\C-f": "$(git-files)\e\C-e\er"'
bind '"\C-f\C-r": "$(git-branches)\e\C-e\er"'
bind '"\C-f\C-t": "$(git-tags)\e\C-e\er"'
bind '"\C-f\C-h": "$(git-commit-hashes)\e\C-e\er"'

# --- "nb" note selector

N-note-list() {
  N list -t note --no-color |
    grep -E '^\[[0-9]+\]'  |
    sed -r 's/^\[(.*)\]\ (.*)$/\1 \2/' |
  fzf --height 70% \
    --preview "N show -p {1} | head -n 200 | bat -l md" \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:60% |
  cut -d$' ' -f1
}

N-bookmark-list() {
  N list -t note --no-color |
    grep -E '^\[[0-9]+\]'  |
    sed -r 's/^\[(.*)\]\ (.*)$/\1 \2/' |
  fzf --height 70% \
    --preview "N show -p {1} | head -n 200 | bat -l md" \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:60% |
  cut -d$' ' -f1
}

bind '"\C-g\C-g": "$(N-note-list)\e\C-e\er"'
bind '"\C-g\C-f": "$(N-bookmark-list)\e\C-e\er"'

# ---- unix keyboard shortcuts ----

# redraw shell prompt
bind '"\er": redraw-current-line'

# expand shell patterns with Space key
bind 'Space: magic-space'

# Alt-down goes back in the pushd dirs stack, alt-up goes forward
bind '"\e[1;3A": "pushd +1 >/dev/null\r"'
bind '"\e[1;3B": "pushd -0 >/dev/null\r"'

# <c-j> to run a command with "ts" prepended, which prints timing information
bind "\C-j": "\C-ats \C-m"

# ---- other aliases ----
export EDITOR='nvim'
export VISUAL='nvim'
export DELTA_PAGER='bat'
export PAGER='less'
export MANPAGER='most'
export BROWSER='lynx'
export TIMEFORMAT='real: %R, user: %U, sys: %S'

shopt -s nocaseglob

alias less='less -K'
alias rm='rm -v -I'
alias rmf='rm -v -I -rf'
alias mv='mv -v'
alias cl='clear'
alias ge='grep -E'
alias gv='grep -v'
alias path='echo $PATH | tr ":" "\n"'
alias k9='kill -9'
alias wcl='wc -l'

kill-port() {
  fuser -k $1/tcp
}

# fuzzy cd
zd() {
  pushd $(z -e $1) >/dev/null
}

# show pushd directory stack
alias dv='dirs -v'

# bazel shortcuts
alias bb='bazel build'
alias bbv='bazel build --verbose_failures --sandbox_debug'
alias bbw='bazel build --workspace_status_command'
alias br='bazel run'
alias brv='bazel run --verbose_failures --sandbox_debug'
alias brw='bazel run --workspace_status_command'
alias bq='bazel query'
alias bc='bazel clean'
alias bce='bazel clean --expunge'
alias bqb='bazel query --output=build'
alias bqr='bazel query --output=run'
alias bf='bazel fetch'
alias bi='bazel info'

function bbc() {
  bazel build $@ 2>&1 | bat -l bash --style grid --paging never
}


function bbp() {
  bazel build $@ 2>&1 | bat -l python --style grid --paging never
}

alias ibazel="ypx @bazel/ibazel:ibazel"
alias gb='ypx @bazel/bazel:bazel --nohome_rc'
alias gbb='ypx @bazel/bazel:bazel --nohome_rc build'
alias gbr='ypx @bazel/bazel:bazel --nohome_rc run'
alias gbq='ypx @bazel/bazel:bazel --nohome_rc query'

alias jira='ypx jira'
alias ji='ypx jira issue'
alias jj='ypx jira issue | grep In.Progress'

alias tldr='ypx tldr'
alias prettier='ypx prettier'
alias http-server='ypx http-server'
alias gtop='ypx gtop'
alias readable='ypx readability-cli:readable'

alias sb='. ~/.bashrc'
alias sbl='. ~/.bashrc.local'
alias seb='nvim ~/.bashrc && . ~/.bashrc'
alias sebl='nvim ~/.bashrc.local && . ~/.bashrc'

alias c='xclip -selection clipboard'
alias v='xclip -selection cliboard -o'

alias rga='rg -A5 -B5'

alias ..='cd ..'
function - {
  cd -
}

# FZF fuzzy finder settings
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse'
export FZF_CTRL_T_COMMAND='rg --files 2>/dev/null'
export FZF_ALT_C_COMMAND='fd --type d 2>/dev/null'
export FZF_CTRL_T_OPTS='
  --preview "bat --style=numbers,header --color=always {}"
  --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up"
  --preview-window=right:70%'

if [ "$(uname)" != "Darwin" ]; then
  complete -F _fzf_dir_completion -o default -o bashdefault tree
fi

alias dd='docker'
alias db='docker build .'
alias dps='docker ps'
alias di='docker images'

if [ "$(uname)" != "Darwin" ]; then
  complete -F _complete_alias d
fi

alias e='nvim'

if [ "$(uname)" != "Darwin" ]; then
  complete -F _complete_alias e
fi

alias nvim-format='xargs nvim -n "+set nomore" "+bufdo YcmCompleter Format"'

alias psa='ps -a | grep'
alias kk='kill -9'
alias jl='jobs -l'
alias killjobs="kill -9 $(jobs -p)"
alias k='kill'

if [ "$(uname)" != "Darwin" ]; then
  complete -F _complete_alias k
fi

# todo tools
alias t-new='echo "$(date +%H:%M)" >> ~/.todo'
alias t-newday="echo $'\n'$(date +%Y-%m-%d)$'\n' >> ~/.todo"
alias t-edit='nvim ~/.todo'
alias t-entry='echo >> ~/.todo'
alias t-tail='tail ~/.todo'
alias t-amend='LAST_TIME=$(tail -1 ~/.todo | sed -n '\''s/^\([0-9]*:[0-9]*\) .*/\1/p'\'') && [[ ! -z "$LAST_TIME" ]] && tmpfile=$(mktemp) && head -n -1 ~/.todo > $tmpfile && cat $tmpfile > ~/.todo && rm $tmpfile && echo "$LAST_TIME" >> ~/.todo'
alias t-recover='sed "$d" -i .shell-recordings/$(date +%Y-%m-%d).cast'

# nnn file manager
n() {
    # Block nesting of nnn in subshells
    if [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    nnn -c $@
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}
export NNN_PLUG='x:_chmod +x $nnn;g:_git status;o:fzopen;t:_tree $nnn;c:_~/bin/copyfilepath $nnn'
export NNN_CONTEXT_COLORS='4123'
export NNN_OPENER="bat --paging always"

alias ni='npm init -y'
alias nb='npm run build'
alias ns='npm start'
alias nt='npm test'
alias nr='npm run'

alias pv='python --version'
alias nv='node -v'

# asciinema shell recordings
function rec() {
  REC_FILE="$HOME/.shell-recordings/$(date +%Y-%m-%d).cast"
  echo "$REC_FILE"
  if [ -f "$REC_FILE" ]; then
    asciinema rec -i 1 --append "$REC_FILE"
  else
    asciinema rec -i 1 "$REC_FILE"
  fi
}
alias recplay='asciinema play -i 0.2'

# yadm dotfiles manager
yadm-git-files() {
  yadm -c color.status=always status --short |
  fzf --height 50% -m --ansi --nth 2..,.. \
    --preview '(yadm diff --color=always -- {-1} | sed 1,4d; bat --color always {-1})' \
    --bind "alt-j:preview-down,alt-k:preview-up,alt-d:preview-page-down,alt-u:preview-page-up" \
    --preview-window=right:70% |
  cut -c4- | sed 's/.* -> //'
}

alias yy='yadm'
alias ya='yadm add'
alias yco='yadm checkout'
alias ysh='yadm show'
alias yd='yadm diff'
alias yds='yadm diff --stat'
alias yl='yadm list'
alias yr='yadm reset'
alias yc='yadm commit --verbose'
alias ycc='yadm commit --amend --verbose'
alias yac='yadm add $(yadm-git-files); yadm commit --verbose'
alias yca='yadm commit -a --verbose'
alias ys='yadm status'
alias yp='yadm pull origin master --rebase; yadm push'
alias ypl='yadm pull origin master --rebase'

# searching and opening web links
s() {
  # must use $*, not $@
  lynx https://duckduckgo.com/?q="$*"
}
alias l="lynx"

# lynx config location
export LYNX_CFG=$HOME/.config/lynx/lynx.cfg
export LYNX_LSS=$HOME/.config/lynx/lynx.lss

# bat style
export BAT_STYLE=grid,snip
export BAT_THEME=base16

# send to trash. alternative to `rm`.
alias trash='$HOME/.pyenv/versions/3.7.0/bin/trash-put'

# select directors with fzf
list-dirs() {
  fd ${1:-.} -t d |
  fzf --height 50% --multi --ansi
}
bind '"\C-f\C-d": "$(list-dirs)\e\C-e\er"'
bind '"\C-p": "$(git-ls-files)\e\C-e\er"'

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
onfilechange() {
  while inotifywait -e modify -e close_write $1 2>/dev/null; do
    bash -li -c "$2" 2>&1 | bat -l python --style grid --paging never
  done
}
onfilechange-plain() {
  while inotifywait -e modify -e close_write $1 2>/dev/null; do
    bash -li -c "$2"
  done
}
watchandrun() {
  while inotifywait -e modify -e close_write $1 2>/dev/null; do
    bash -li -c "$1 $2" 2>&1 | bat -l python --style grid --paging never
  done
}
watchandrun-plain() {
  while inotifywait -e modify -e close_write $1 2>/dev/null; do
    bash -li -c "$1 $2"
  done
}

# make watch command always interpret colors and show differences between
# successive updates
alias watch='watch --color --differences'

# tar
alias tvf='tar tvf'
alias xvf='tar xvf'

# ---- load local customization file ----
[ -s "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

# ---- end ----

