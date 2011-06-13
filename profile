#!/bin/sh

export CLICOLOR=1
export LSCOLORS=exgxfxDxcxDxDxCxCxHbHb
export GREP_OPTIONS="--exclude=\*.svn\*"
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Shortcuts
# =========
alias mv="mv -i"
alias cp="cp -i"
alias ls="ls -G"

p() {
    cd ~/Work/$1*
    [ -f bin/activate ] && source bin/activate
    [ -f environment/bin/activate ] && source environment/bin/activate
}

c() {
    if [ -d "$PROJDIR" ]; then
        cd "$PROJDIR"
    else
        [ -d "$VIRTUAL_ENV" ] && cd $VIRTUAL_ENV
    fi
}


# Language Settings
# =================

# Python
[ -d "/Library/Frameworks/Python.framework/Versions/2.6" ] && PATH="/Library/Frameworks/Python.framework/Versions/2.6/bin:${PATH}"
[ -d "/Library/Frameworks/Python.framework/Versions/2.7" ] && PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
[ -d "/usr/local/google_appengine" ] && PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
[ -f "${HOME}/.pystartup.py" ] && PYTHONSTARTUP="${HOME}/.pystartup.py"
export PYTHONPATH
export PYTHONSTARTUP
export MACOSX_DEPLOYMENT_TARGET=10.6
export ARCHFLAGS="-arch i386 -arch x86_64"
source ~/.local/bin/django_bash_completion

[ -d "${HOME}/.gem/ruby/1.8/bin" ] && PATH="${PATH}:${HOME}/.gem/ruby/1.8/bin" # Ruby Settings
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"  # This loads RVM into a shell session.

[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home" # Java

# Other PATHS
[ -d "/usr/local/git" ] && PATH="/usr/local/git/bin:${PATH}"
[ -d "/usr/local/mysql" ] && PATH="/usr/local/mysql/bin:${PATH}"
[ -d "/Library/PostgreSQL/9.0/bin/" ] && PATH="/Library/PostgreSQL/9.0/bin:${PATH}"
[ -d "/usr/local/node" ] && PATH="/usr/local/node/bin:${PATH}"
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"
export PATH
