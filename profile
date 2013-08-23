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


# Basic PATH (speedup path_helper)
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin

# Homebrew
# ========
export HOMEBREW_HOME="/usr/local"
PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin:$PATH"


# Languages
# =========

# Python
[ -d "${HOMEBREW_HOME}/share/python" ] && PATH="${HOMEBREW_HOME}/share/python:$PATH"
[ -d "/usr/local/google_appengine" ] && PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
[ -d "${HOME}/.python" ] || mkdir -p "${HOME}/.python"
[ -f "${HOME}/.pystartup.py" ] && export PYTHONSTARTUP="${HOME}/.pystartup.py"
[ -d "${HOME}/Work" ] && export PROJECT_HOME="${HOME}/Work"
[ -d "${PROJECT_HOME}/_Environments" ] && export WORKON_HOME="${PROJECT_HOME}/_Environments"
[ -d "${HOME}/.python" ] && export VIRTUALENVWRAPPER_HOOK_DIR="${HOME}/.python"
[ -d "${HOME}/.python" ] && export VIRTUALENVWRAPPER_LOG_DIR="${HOME}/.python"
export PYTHONPATH

[ -f "${HOMEBREW_HOME}/share/python/virtualenvwrapper.sh" ] && source "${HOMEBREW_HOME}/share/python/virtualenvwrapper.sh"
p() { workon $(workon | sed -n "/^$1.*/p" | head -1) }
c() { cdproject $* }


# Ruby
[ -d "${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin" ] && PATH="${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin:$PATH"

# Java
[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"

# Javascript/Node.js
[ -d "${HOMEBREW_HOME}/share/npm/bin" ] && PATH="${HOMEBREW_HOME}/share/npm/bin:${PATH}"


# Local
# =====
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"


# Completions
# ===========
ls "${HOMEBREW_HOME}"/etc/bash_completion.d/* \
     "${HOME}"/.local/etc/bash_completion.d/* | while read f; do
    source "${f}"
done


# EC2
# ===
[ -d "${HOME}/.local/ec2-api-tools" ] && export EC2_HOME="${HOME}/.local/ec2-api-tools"
[ -d "${HOME}/.local/ec2-api-tools" ] && export PATH="${EC2_HOME}/bin:${PATH}"
export EC2_PRIVATE_KEY="~/.ec2/pk.pem"
export EC2_CERT="~/.ec2/cert.pem"
export EC2_URL="ec2.ap-southeast-1.amazonaws.com"


# Powerline
# =========
function _update_ps1()
{
    export PS1="$(~/.powerline-shell.py --mode flat $?) "
}

[ -x ~/.powerline-shell.py ] && export PROMPT_COMMAND="_update_ps1"


# final export PATH changes
export PATH

