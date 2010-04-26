#!/bin/sh

alias mv="mv -i"
alias cp="cp -i"
alias ls='ls -G'

export CLICOLOR=1
export LSCOLORS=exgxfxDxcxDxDxCxCxHbHb
export PATH=$PATH:$HOME/bin
export GREP_OPTIONS="--exclude=\*.svn\*"
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Python Environment
export PYTHONSTARTUP="$HOME/.pystartup.py"
export WORKON_HOME="$HOME/Work/projects"
source ~/bin/django_bash_completion

# Java
export JAVA_HOME="/Library/Java/Home"

# Ruby
RUBYBINDIR="$HOME/.gem/ruby/1.8/bin"
if [ -d "$RUBYBINDIR" ]; then
    export PATH="$RUBYBINDIR:$PATH"
fi

# Shortcuts
p() {
    cd ~/Work/$1*
    [ -f bin/activate ] && source bin/activate
}

c() {
    [ -d "$VIRTUAL_ENV" ] && cd $VIRTUAL_ENV
}

