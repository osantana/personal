#!/bin/sh

export CLICOLOR=1
export LSCOLORS=exgxfxDxcxDxDxCxCxHbHb
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
    [ -f env/bin/activate ] && source env/bin/activate
    [ -f environment/bin/activate ] && source environment/bin/activate
    proj_name="$(basename $(dirname $VIRTUAL_ENV))"
    PS1="\[\e[0;32m\](\[\e[0;33m\]${proj_name}\[\e[0;32m\])\[\e[0m\][\u@\h \W]\$ "
    export PS1
}

c() {
    if [ -d "$PROJDIR" ]; then
        cd "$PROJDIR"
    else
        [ -d "$VIRTUAL_ENV" ] && cd $(dirname $VIRTUAL_ENV)
    fi
}


# Languages
# =========

# Python
[ -d "/usr/local/google_appengine" ] && PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
[ -f "${HOME}/.pystartup.py" ] && PYTHONSTARTUP="${HOME}/.pystartup.py"
export PYTHONPATH
export PYTHONSTARTUP

# Java
[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"


# Homebrew
# ========
export HOMEBREW_HOME="/usr/local"
PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin:$PATH"

# Homebrew's Python Scripts
[ -d "${HOMEBREW_HOME}/share/python" ] && PATH="${HOMEBREW_HOME}/share/python:$PATH"


# Local
# =====
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"


# Completions
# ===========
ls "${HOMEBREW_HOME}"/etc/bash_completion.d/* \
     "${HOME}"/.local/etc/bash_completion.d/* | while read f; do
    source "${f}"
done

# export PATH changes
export PATH
