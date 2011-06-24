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


# Languages
# =========

# Python
[ -d "/usr/local/share/python" ] && PATH="/usr/local/share/python:$PATH"
[ -d "/usr/local/google_appengine" ] && PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
[ -f "${HOME}/.pystartup.py" ] && PYTHONSTARTUP="${HOME}/.pystartup.py"
export PYTHONPATH
export PYTHONSTARTUP
export MACOSX_DEPLOYMENT_TARGET=10.6
export ARCHFLAGS="-arch i386 -arch x86_64"

# Java
[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"


# Homebrew
# ========
export HOMEBREW_HOME="/usr/local"

HOMEBREW_OVERRIDES="python git"
for OVERRIDE in $HOMEBREW_OVERRIDES; do
    # FIXME: get the higher version instead of the most recent installation
    OVERRIDEDIR=$(ls -1rtd ${HOMEBREW_HOME}/Cellar/${OVERRIDE}/*/bin | tail -1)
    [ -d "${OVERRIDEDIR}" ] && PATH="${OVERRIDEDIR}:$PATH"
done


# Local
# =====
[ -d "${HOME}/.local/bin" ] && export PATH="${HOME}/.local/bin:${PATH}"


# Completions
# ===========
ls "${HOMEBREW_HOME}"/etc/bash_completion.d/* \
     "${HOME}"/.local/etc/bash_completion.d/* | while read f; do
    source "${f}"
done

