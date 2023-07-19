#! bash oh-my-bash.module
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
  echo $($_omb_git_git_cmd remote -v | cut -d':' -f 2)
}
# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}
# Warn if the current branch is a WIP
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

#
# Aliases
# (sorted alphabetically)
#

alias g='command git'

alias ga='command git add'
alias gaa='command git add --all'
alias gapa='command git add --patch'
alias gau='command git add --update'

alias gb='command git branch'
alias gba='command git branch -a'
alias gbd='command git branch -d'
alias gbD='command git branch --delete --force'
alias gbda='command git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbl='command git blame -b -w'
alias gbnm='command git branch --no-merged'
alias gbr='command git branch --remote'
alias gbs='command git bisect'
alias gbsb='command git bisect bad'
alias gbsg='command git bisect good'
alias gbsr='command git bisect reset'
alias gbss='command git bisect start'

alias gc='command git commit -v'
alias gc!='command git commit -v --amend'
alias gcn!='command git commit -v --no-edit --amend'
alias gca='command git commit -v -a'
alias gca!='command git commit -v -a --amend'
alias gcan!='command git commit -v -a --no-edit --amend'
alias gcans!='command git commit -v -a -s --no-edit --amend'
alias gcam='command git commit -a -m'
alias gcsm='command git commit -s -m'
alias gcb='command git checkout -b'
alias gcf='command git config --list'
alias gcl='command git clone --recursive'
alias gclean='command git clean -fd'
alias gpristine='command git reset --hard && git clean -dfx'
alias gcm='command git checkout master'
alias gcd='command git checkout develop'
alias gcmsg='command git commit -m'
alias gco='command git checkout'
alias gcount='command git shortlog -sn'
#compdef _git gcount complete -F _git gcount
alias gcp='command git cherry-pick'
alias gcpa='command git cherry-pick --abort'
alias gcpc='command git cherry-pick --continue'
alias gcps='command git cherry-pick -s'
alias gcs='command git commit -S'

alias gd='command git diff'
alias gdca='command git diff --cached'
alias gdct='command git describe --tags `git rev-list --tags --max-count=1`'
alias gdt='command git diff-tree --no-commit-id --name-only -r'
alias gdw='command git diff --word-diff'
alias gdtool='command git difftool -d'

function gdv {
  command git diff -w "$@" | view -
}
#compdef _git gdv=git-diff

alias gf='command git fetch'
alias gfa='command git fetch --all --prune'
alias gfo='command git fetch origin'

function gfg {
  command git ls-files | grep "$@"
}
#compdef _grep gfg

alias gg='command git gui citool'
alias gga='command git gui citool --amend'

function ggf {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  command git push --force origin "${b:=$1}"
}
#compdef _git ggf=git-checkout

function ggl {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    command git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    command git pull origin "${b:=$1}"
  fi
}
#compdef _git ggl=git-checkout

function ggp {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    command git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    command git push origin "${b:=$1}"
  fi
}
#compdef _git ggp=git-checkout

function ggpnp {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "${*}" && ggp "${*}"
  fi
}
#compdef _git ggpnp=git-checkout

function ggu {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  command git pull --rebase origin "${b:=$1}"
}
#compdef _git ggu=git-checkout

alias ggpur='ggu'
#compdef _git ggpur=git-checkout

alias ggpull='command git pull origin $(git_current_branch)'
#compdef _git ggpull=git-checkout

alias ggpush='command git push origin $(git_current_branch)'
#compdef _git ggpush=git-checkout

alias ggsup='command git branch --set-upstream-to=origin/$(git_current_branch)'
alias gpsup='command git push --set-upstream origin $(git_current_branch)'

alias ghh='command git help'

alias gignore='command git update-index --assume-unchanged'
alias gignored='command git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='command git svn dcommit && git push github master:svntrunk'
#compdef _git git-svn-dcommit-push=git

alias gk='\gitk --all --branches'
#compdef _git gk='command gitk'
alias gke='\gitk --all $(git log -g --pretty=%h)'
#compdef _git gke='command gitk'

alias gl='command git pull'
alias glg='command git log --stat'
alias glgp='command git log --stat -p'
alias glgg='command git log --graph'
alias glgga='command git log --graph --decorate --all'
alias glgm='command git log --graph --max-count=10'
alias glo='command git log --oneline --decorate'
alias glol="command git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glola="command git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias glog='command git log --oneline --decorate --graph'
alias gloga='command git log --oneline --decorate --graph --all'
alias glp="_git_log_prettily"
#compdef _git glp=git-log

alias gm='command git merge'
alias gmom='command git merge origin/master'
alias gmt='command git mergetool --no-prompt'
alias gmtvim='command git mergetool --no-prompt --tool=vimdiff'
alias gmum='command git merge upstream/master'

alias gp='command git push'
alias gpd='command git push --dry-run'
alias gpoat='command git push origin --all && git push origin --tags'
#compdef _git gpoat=git-push
alias gpu='command git push upstream'
alias gpv='command git push -v'

alias gr='command git remote'
alias gra='command git remote add'
alias grb='command git rebase'
alias grba='command git rebase --abort'
alias grbc='command git rebase --continue'
alias grbi='command git rebase -i'
alias grbm='command git rebase master'
alias grbs='command git rebase --skip'
alias grh='command git reset HEAD'
alias grhh='command git reset HEAD --hard'
alias grmv='command git remote rename'
alias grrm='command git remote remove'
alias grset='command git remote set-url'
alias grt='cd $(command git rev-parse --show-toplevel || echo ".")'
alias gru='command git reset --'
alias grup='command git remote update'
alias grv='command git remote -v'

alias gsb='command git status -sb'
alias gsd='command git svn dcommit'
alias gsi='command git submodule init'
alias gsps='command git show --pretty=short --show-signature'
alias gsr='command git svn rebase'
alias gss='command git status -s'
alias gst='command git status'
alias gsta='command git stash save'
alias gstaa='command git stash apply'
alias gstc='command git stash clear'
alias gstd='command git stash drop'
alias gstl='command git stash list'
alias gstp='command git stash pop'
alias gsts='command git stash show --text'
alias gsu='command git submodule update'

alias gts='command git tag -s'
alias gtv='command git tag | sort -V'

alias gunignore='command git update-index --no-assume-unchanged'
alias gunwip='command git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='command git pull --rebase'
alias gupv='command git pull --rebase -v'
alias gupa='command git pull --rebase --autostash'
alias gupav='command git pull --rebase --autostash -v'
alias glum='command git pull upstream master'

alias gwch='command git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='command git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'

alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'
