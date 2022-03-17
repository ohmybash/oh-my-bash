#! bash oh-my-bash.module

alias gob='go build'
alias goc='go clean'
alias god='go doc'
alias gof='go fmt'
alias gofa='go fmt ./...'
alias gog='go get'
alias goi='go install'
alias gol='go list'
alias gom='go mod'
alias gop='cd $GOPATH'
alias gopb='cd $GOPATH/bin'
alias gops='cd $GOPATH/src'
alias gor='go run'
alias got='go test'
alias gov='go vet'

# Set $GOPATH and $GOPATH/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin