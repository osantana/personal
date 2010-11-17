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

# Shortcuts
p() {
    cd ~/Work/$1*
    [ -f bin/activate ] && source bin/activate
}

c() {
    if [ -d "$PROJDIR" ]; then
        cd "$PROJDIR"
    else
        [ -d "$VIRTUAL_ENV" ] && cd $VIRTUAL_ENV
    fi
}

# Python Settings
export PATH="/Library/Frameworks/Python.framework/Versions/2.6/bin:${PATH}"
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PYTHONSTARTUP="$HOME/.pystartup.py"
source ~/bin/django_bash_completion

if [ -d "/usr/local/google_appengine" ]; then
    export PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
fi

# MySQL Settings
export PATH="${PATH}:/usr/local/mysql/bin"

# Java Settings
export JAVA_HOME="/Library/Java/Home"

# Ruby Settings
RUBYBINDIR="$HOME/.gem/ruby/1.8/bin"
if [ -d "$RUBYBINDIR" ]; then
    export PATH="$RUBYBINDIR:$PATH"
fi
