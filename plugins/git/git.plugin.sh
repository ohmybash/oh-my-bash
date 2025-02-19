#! bash oh-my-bash.module
_omb_module_require completion:git

#
# Functions
#

# The name of the current branch
# Back-compatibility wrapper for when this function was defined here in
# the plugin, before being pulled in to core lib/git.zsh as git_current_branch()
# to fix the core -> git plugin dependency.
function current_branch() {
  git_current_branch
}
# The list of remotes
function current_repository() {
  if ! $_omb_git_git_cmd rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi
  _omb_util_print $($_omb_git_git_cmd remote -v | cut -d':' -f 2)
}
# Warn if the current branch is a WIP
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    _omb_util_print "WIP!!"
  fi
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/"$branch"; then
      _omb_util_print "$branch"
      return
    fi
  done
  _omb_util_print develop
}

# Check if main exists and use instead of master
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
    if command git show-ref -q --verify "$ref"; then
      _omb_util_print "${ref##*/}"
      return
    fi
  done
  _omb_util_print master
}

#
# Aliases
#
# From Oh-My-Zsh:
# https://github.com/ohmyzsh/ohmyzsh/blob/f36c6db0eac17b022eee87411e6996a5f5fc8457/plugins/git/git.plugin.zsh
#

alias g='command git'
__git_complete g _git

alias ga='command git add'
__git_complete ga _git_add
alias gaa='command git add --all'
__git_complete gaa _git_add
alias gapa='command git add --patch'
__git_complete gapa _git_add
alias gau='command git add --update'
__git_complete gau _git_add
alias gav='command git add --verbose'
__git_complete gav _git_add
alias gwip='command git add -A; command git rm $(git ls-files --deleted) 2> /dev/null; command git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'

alias gam='command git am'
__git_complete gam _git_am
alias gama='command git am --abort'
__git_complete gama _git_am
alias gamc='command git am --continue'
__git_complete gamc _git_am
alias gamscp='command git am --show-current-patch'
__git_complete gamscp _git_am
alias gams='command git am --skip'
__git_complete gams _git_am

alias gap='command git apply'
__git_complete gap _git_apply
alias gapt='command git apply --3way'
__git_complete gapt _git_apply

alias gbl='command git blame -b -w'

alias gb='command git branch'
__git_complete gb _git_branch
alias gbD='command git branch --delete --force'
__git_complete gbD _git_branch
alias gba='command git branch -a'
__git_complete gba _git_branch
alias gbd='command git branch -d'
__git_complete gbd _git_branch
alias gbda='command git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null'
alias gbg='LANG=C command git branch -vv | grep ": gone\]"'
alias gbgD='LANG=C command git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | command xargs git branch -D'
alias gbgd='LANG=C command git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | command xargs git branch -d'
alias gbm='command git branch --move'
__git_complete gbm _git_branch
alias gbnm='command git branch --no-merged'
__git_complete gbnm _git_branch
alias gbr='command git branch --remote'
__git_complete gbr _git_branch
alias gbsc='command git branch --show-current'
__git_complete gbsc _git_branch
alias ggsup='command git branch --set-upstream-to="origin/$(git_current_branch)"'
__git_complete ggsup _git_branch

alias gbs='command git bisect'
__git_complete gbs _git_bisect
alias gbsb='command git bisect bad'
__git_complete gbsb _git_bisect
alias gbsg='command git bisect good'
__git_complete gbsg _git_bisect
alias gbsn='command git bisect new'
__git_complete gbsn _git_bisect
alias gbso='command git bisect old'
__git_complete gbso _git_bisect
alias gbsr='command git bisect reset'
__git_complete gbsr _git_bisect
alias gbss='command git bisect start'
__git_complete gbss _git_bisect

alias gcb='command git checkout -b'
__git_complete gcb _git_checkout
alias gcd='command git checkout "$(git_develop_branch)"'
__git_complete gcd _git_checkout
alias gcm='command git checkout "$(git_main_branch)"'
__git_complete gcm _git_checkout
alias gco='command git checkout'
__git_complete gco _git_checkout
alias gcor='command git checkout --recurse-submodules'
__git_complete gcor _git_checkout

alias gcp='command git cherry-pick'
__git_complete gcp _git_cherry_pick
alias gcpa='command git cherry-pick --abort'
__git_complete gcpa _git_cherry_pick
alias gcpc='command git cherry-pick --continue'
__git_complete gcpc _git_cherry_pick
alias gcps='command git cherry-pick -s'
__git_complete gcps _git_cherry_pick

alias gcl='command git clone --recursive'
__git_complete gcl _git_clone
function gccd() {
  command git clone --recurse-submodules "$@"
  local lastarg=$_
  [[ -d $lastarg ]] && cd "$lastarg" && return
  lastarg=${lastarg##*/}
  cd "${lastarg%.git}"
}
#compdef _git gccd=git-clone
__git_complete gccd _git_clone

alias gclean='command git clean -fd'
__git_complete gclean _git_clean

alias gc!='command git commit --verbose --amend'
__git_complete gc! _git_commit
alias gc='command git commit --verbose'
__git_complete gc _git_commit
alias gca!='command git commit --verbose --all --amend'
__git_complete gca! _git_commit
alias gca='command git commit --verbose --all'
__git_complete gca _git_commit
alias gcam='command git commit --all --message'
__git_complete gcam _git_commit
alias gcan!='command git commit --verbose --all --no-edit --amend'
__git_complete gcan! _git_commit
alias gcans!='command git commit --verbose --all --signoff --no-edit --amend'
__git_complete gcans! _git_commit
alias gcas='command git commit --all --signoff'
__git_complete gcas _git_commit
alias gcasm='command git commit --all --signoff --message'
__git_complete gcasm _git_commit
alias gcmsg='command git commit --message'
__git_complete gcmsg _git_commit
alias gcn!='command git commit --verbose --no-edit --amend'
__git_complete gcn! _git_commit
alias gcs='command git commit --gpg-sign'
__git_complete gcs _git_commit
alias gcsm='command git commit --signoff --message'
__git_complete gcsm _git_commit
alias gcss='command git commit --gpg-sign --signoff'
__git_complete gcss _git_commit
alias gcssm='command git commit --gpg-sign --signoff --message'
__git_complete gcssm _git_commit

alias gcf='command git config --list'
__git_complete gcf _git_config

alias gdct='command git describe --tags `git rev-list --tags --max-count=1`'

alias gd='command git diff'
__git_complete gd _git_diff
alias gdca='command git diff --cached'
__git_complete gdca _git_diff
alias gdcw='command git diff --cached --word-diff'
__git_complete gdcw _git_diff
alias gds='command git diff --staged'
__git_complete gds _git_diff
alias gdw='command git diff --word-diff'
__git_complete gdw _git_diff
alias gdup='command git diff @{upstream}'
__git_complete gdup _git_diff
function gdnolock() {
  command git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
#compdef _git gdnolock=git-diff
__git_complete gdnolock _git_diff
function gdv {
  command git diff -w "$@" | view -
}
#compdef _git gdv=git-diff
__git_complete gdv _git_diff

alias gdt='command git diff-tree --no-commit-id --name-only -r'
__git_complete gdt _git_diff

alias gdtool='command git difftool -d'
__git_complete gdtool _git_difftool

alias gf='command git fetch'
__git_complete gf _git_fetch
alias gfa='command git fetch --all --prune'
__git_complete gfa _git_fetch
alias gfo='command git fetch origin'
# jobs=<n> was added in git 2.8
# alias gfa='git fetch --all --prune --jobs=10' \
__git_complete gfo _git_fetch

alias gg='command git gui citool'
alias gga='command git gui citool --amend'

alias ghh='command git help'
__git_complete ghh _git_help

alias glg='command git log --stat'
__git_complete glg _git_log
alias glgg='command git log --graph'
__git_complete glgg _git_log
alias glgga='command git log --graph --decorate --all'
__git_complete glgga _git_log
alias glgm='command git log --graph --max-count=10'
__git_complete glgm _git_log
alias glgp='command git log --stat -p'
__git_complete glgp _git_log
alias glo='command git log --oneline --decorate'
__git_complete glo _git_log
alias glod='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
__git_complete glod _git_log
alias glods='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
__git_complete glods _git_log
alias glog='command git log --oneline --decorate --graph'
__git_complete glog _git_log
alias gloga='command git log --oneline --decorate --graph --all'
__git_complete gloga _git_log
alias glol='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
__git_complete glol _git_log
alias glola='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
__git_complete glola _git_log
alias glols='command git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
__git_complete glols _git_log
# Pretty log messages
function _git_log_prettily(){
  if [[ $1 ]]; then
    command git log --pretty="$1"
  fi
}
alias glp='_git_log_prettily'
#compdef _git glp=git-log
__git_complete glp _git_log

alias gignored='command git ls-files -v | grep "^[[:lower:]]"'
alias gfg='command git ls-files | grep'

alias gm='command git merge'
__git_complete gm _git_merge
alias gma='command git merge --abort'
__git_complete gma _git_merge
alias gmom='command git merge "origin/$(git_main_branch)"'
__git_complete gmom _git_merge
alias gms='command git merge --squash'
__git_complete gms _git_merge
alias gmum='command git merge "upstream/$(git_main_branch)"'
__git_complete gmum _git_merge

alias gmt='command git mergetool --no-prompt' # deprecate?
__git_complete gmt _git_mergetool
alias gmtvim='command git mergetool --no-prompt --tool=vimdiff' # deprecate?
__git_complete gmtvim _git_mergetool
alias gmtl='command git mergetool --no-prompt'
__git_complete gmtl _git_mergetool
alias gmtlvim='command git mergetool --no-prompt --tool=vimdiff'
__git_complete gmtlvim _git_mergetool

alias ggpull='command git pull origin "$(git_current_branch)"'
__git_complete ggpull _git_pull
alias ggpur='ggu'
alias gl='command git pull'
__git_complete gl _git_pull
alias gluc='command git pull upstream "$(git_current_branch)"'
__git_complete gluc _git_pull
alias glum='command git pull upstream "$(git_main_branch)"'
__git_complete glum _git_pull
alias gpr='command git pull --rebase'
__git_complete gpr _git_pull
alias gup='command git pull --rebase'
__git_complete gup _git_pull
alias gupa='command git pull --rebase --autostash'
__git_complete gupa _git_pull
alias gupav='command git pull --rebase --autostash --verbose'
__git_complete gupav _git_pull
alias gupom='command git pull --rebase origin "$(git_main_branch)"'
__git_complete gupom _git_pull
alias gupomi='command git pull --rebase=interactive origin "$(git_main_branch)"'
__git_complete gupomi _git_pull
alias gupv='command git pull --rebase --verbose'
__git_complete gupv _git_pull
function ggl {
  if (($# != 0 && $# != 1)); then
    command git pull origin "$*"
  else
    local b=
    (($# == 0)) && b=$(git_current_branch)
    command git pull origin "${b:-$1}"
  fi
}
__git_complete ggl _git_pull
function ggu {
  local b=
  (($# != 1)) && b=$(git_current_branch)
  command git pull --rebase origin "${b:-$1}"
}
#compdef _git ggl=git-checkout
#compdef _git ggpull=git-checkout
#compdef _git ggpur=git-checkout
#compdef _git ggu=git-checkout
__git_complete ggu _git_pull

alias ggpush='command git push origin "$(git_current_branch)"'
__git_complete ggpush _git_push
alias gp='command git push'
__git_complete gp _git_push
alias gpd='command git push --dry-run'
__git_complete gpd _git_push
alias gpf!='command git push --force'
__git_complete gpf! _git_push
alias gpf='command git push --force-with-lease'
__git_complete gpf _git_push
alias gpoat='command git push origin --all && command git push origin --tags'
__git_complete gpoat _git_push
alias gpod='command git push origin --delete'
__git_complete gpod _git_push
alias gpsup='command git push --set-upstream origin "$(git_current_branch)"'
__git_complete gpsup _git_push
alias gpsupf='command git push --set-upstream origin "$(git_current_branch)" --force-with-lease'
__git_complete gpsupf _git_push
alias gpu='command git push upstream'
__git_complete gpu _git_push
alias gpv='command git push --verbose'
__git_complete gpv _git_push
#is-at-least 2.30 "$git_version" && alias gpf='git push --force-with-lease --force-if-includes'
#is-at-least 2.30 "$git_version" && alias gpsupf='git push --set-upstream origin "$(git_current_branch)" --force-with-lease --force-if-includes'
function ggf {
  (($# != 1)) && local b=$(git_current_branch)
  command git push --force origin "${b:=$1}"
}
__git_complete ggf _git_push
function ggfl {
  (($# != 1)) && local b=$(git_current_branch)
  command git push --force-with-lease origin "${b:=$1}"
}
__git_complete ggfl _git_push
function ggp {
  if (($# != 0 && $# != 1)); then
    command git push origin "$*"
  else
    (($# == 0)) && local b=$(git_current_branch)
    command git push origin "${b:=$1}"
  fi
}
__git_complete ggp _git_push
function ggpnp {
  if (($# == 0)); then
    ggl && ggp
  else
    ggl "$*" && ggp "$*"
  fi
}
__git_complete ggpnp _git_push
#compdef _git ggf=git-checkout
#compdef _git ggfl=git-checkout
#compdef _git ggp=git-checkout
#compdef _git ggpnp=git-checkout
#compdef _git ggpush=git-checkout
#compdef _git gpoat=git-push

alias grb='command git rebase'
__git_complete grb _git_rebase
alias grba='command git rebase --abort'
__git_complete grba _git_rebase
alias grbc='command git rebase --continue'
__git_complete grbc _git_rebase
alias grbi='command git rebase --interactive'
__git_complete grbi _git_rebase
alias grbo='command git rebase --onto'
__git_complete grbo _git_rebase
alias grbs='command git rebase --skip'
__git_complete grbs _git_rebase
alias grbd='command git rebase "$(git_develop_branch)"'
__git_complete grbd _git_rebase
alias grbm='command git rebase "$(git_main_branch)"'
__git_complete grbm _git_rebase
alias grbom='command git rebase "origin/$(git_main_branch)"'
__git_complete grbom _git_rebase

alias gr='command git remote'
__git_complete gr _git_remote
alias gra='command git remote add'
__git_complete gra _git_remote
alias grmv='command git remote rename'
__git_complete grmv _git_remote
alias grrm='command git remote remove'
__git_complete grrm _git_remote
alias grset='command git remote set-url'
__git_complete grset _git_remote
alias grup='command git remote update'
__git_complete grup _git_remote
alias grv='command git remote --verbose'
__git_complete grv _git_remote

alias gpristine='command git reset --hard && command git clean --force -dfx'
alias grh='command git reset'
__git_complete grh _git_reset
alias grhh='command git reset --hard'
__git_complete grhh _git_reset
alias grhk='command git reset --keep'
__git_complete grhk _git_reset
alias grhs='command git reset --soft'
__git_complete grhs _git_reset
alias groh='command git reset "origin/$(git_current_branch)" --hard'
__git_complete groh _git_reset
alias grt='cd $(command git rev-parse --show-toplevel || _omb_util_print ".")'
alias gru='command git reset --'
__git_complete gru _git_reset

alias grs='command git restore'
__git_complete grs _git_restore
alias grss='command git restore --source'
__git_complete grss _git_restore
alias grst='command git restore --staged'
__git_complete grst _git_restore

alias gunwip='command git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && command git reset HEAD~1'
alias grev='command git revert'
__git_complete grev _git_revert

alias grm='command git rm'
__git_complete grm _git_rm
alias grmc='command git rm --cached'
__git_complete grmc _git_rm

alias gcount='command git shortlog --summary --numbered'
__git_complete gcount _git_shortlog
#compdef _git gcount complete -F _git gcount

alias gsh='command git show'
__git_complete gsh _git_show
alias gsps='command git show --pretty=short --show-signature'
__git_complete gsps _git_show

alias gsta='command git stash save'
__git_complete gsta _git_stash
alias gstaa='command git stash apply'
__git_complete gstaa _git_stash
alias gstall='command git stash --all'
__git_complete gstall _git_stash
alias gstc='command git stash clear'
__git_complete gstc _git_stash
alias gstd='command git stash drop'
__git_complete gstd _git_stash
alias gstl='command git stash list'
__git_complete gstl _git_stash
alias gstp='command git stash pop'
__git_complete gstp _git_stash
alias gsts='command git stash show'
__git_complete gsts _git_stash
alias gstu='gsta --include-untracked'
__git_complete gstu _git_stash
#is-at-least 2.13 "$git_version" && alias gsta='command git stash push'

alias gsb='command git status --short --branch'
__git_complete gsb _git_status
alias gss='command git status --short'
__git_complete gss _git_status
alias gst='command git status'
__git_complete gst _git_status

alias gsi='command git submodule init'
__git_complete gsi _git_submodule
alias gsu='command git submodule update'
__git_complete gsu _git_submodule

alias git-svn-dcommit-push='command git svn dcommit && command git push github "$(git_main_branch):svntrunk"'
alias gsd='command git svn dcommit'
__git_complete gsd _git_svn
alias gsr='command git svn rebase'
__git_complete gsr _git_svn
#compdef _git git-svn-dcommit-push=git

alias gsw='command git switch'
__git_complete gsw _git_switch
alias gswc='command git switch --create'
__git_complete gswc _git_switch
alias gswd='command git switch "$(git_develop_branch)"'
__git_complete gswd _git_switch
alias gswm='command git switch "$(git_main_branch)"'
__git_complete gswm _git_switch

alias gta='command git tag --annotate'
__git_complete gta _git_tag
alias gts='command git tag --sign'
__git_complete gts _git_tag
alias gtv='command git tag | sort -V'
__git_complete gtv _git_tag
function gtl {
  command git tag --sort=-v:refname -n --list "$1*"
}
__git_complete gtl _git_tag
#compdef _git gtl=git-tag

alias gignore='command git update-index --assume-unchanged'
alias gunignore='command git update-index --no-assume-unchanged'

alias gwch='command git whatchanged -p --abbrev-commit --pretty=medium'
__git_complete gwch _git_whatchanged

alias gwt='command git worktree'
__git_complete gwt _git_worktree
alias gwta='command git worktree add'
__git_complete gwta _git_worktree
alias gwtls='command git worktree list'
__git_complete gwtls _git_worktree
alias gwtmv='command git worktree move'
__git_complete gwtmv _git_worktree
alias gwtrm='command git worktree remove'
__git_complete gwtrm _git_worktree

alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h)'
# alias gk='\gitk --all --branches &!'
# alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
#compdef _git gk='command gitk'
#compdef _git gke='command gitk'
