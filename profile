#!/bin/sh

# Speedup terminal opening (maintenance operations)
#   sudo rm -f /private/var/log/asl/*.asl /etc/paths.d/*
#   > /etc/paths
#   Use bash -l on login command in Terminal settings


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
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

[ -d "/opt/X11/bin" ] && PATH="${PATH}:/opt/X11/bin"
[ -d "/usr/local/MacGPG2/bin" ] && PATH="${PATH}:/usr/local/MacGPG2/bin"
[ -d "/usr/texbin" ] && PATH="${PATH}:/usr/local/MacGPG2/bin"

# Homebrew
# ========
export HOMEBREW_HOME="/usr/local"
PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin:$PATH"


# Languages
# =========

# Python
[ -d "/usr/local/google_appengine" ] && PYTHONPATH="/usr/local/google_appengine:/usr/local/google_appengine/lib"
[ -d "${HOME}/.python" ] || mkdir -p "${HOME}/.python"
[ -f "${HOME}/.pystartup.py" ] && export PYTHONSTARTUP="${HOME}/.pystartup.py"
export PYTHONPATH

# virtualenvwrapper
[ -d "${HOME}/Work" ] && export PROJECT_HOME="${HOME}/Work"
[ -d "${HOME}/.virtualenvs" ] && export WORKON_HOME="${HOME}/.virtualenvs"
[ -d "${HOME}/.python" ] && export VIRTUALENVWRAPPER_HOOK_DIR="${HOME}/.python"
[ -d "${HOME}/.python" ] && export VIRTUALENVWRAPPER_LOG_DIR="${HOME}/.python"
[ -f "${HOMEBREW_HOME}/share/python/virtualenvwrapper.sh" ] && export VIRTUALENVWRAPPER_SCRIPT="${HOMEBREW_HOME}/share/python/virtualenvwrapper.sh"
[ -f "${HOMEBREW_HOME}/share/python/virtualenvwrapper_lazy.sh" ] && source "${HOMEBREW_HOME}/share/python/virtualenvwrapper_lazy.sh"
[ -f "${HOMEBREW_HOME}/opt/autoenv/activate.sh" ] && source ${HOMEBREW_HOME}/opt/autoenv/activate.sh
p() { workon $(workon | sed -n "/^$1.*/p" | head -1); }
c() { cdproject $*; }

newproject() {
    project="$1"
    [ -d "${WORKON_HOME}/${project}" ] && rm -rf "${WORKON_HOME}/${project}"
    if [ -d "${PROJECT_HOME}/${project}" ]; then
        mv "${PROJECT_HOME}/${project}" "${PROJECT_HOME}/${project}.tmp"
        mkproject "${project}"
        rm -rf "${PROJECT_HOME}/${project}"
        mv "${PROJECT_HOME}/${project}.tmp" "${PROJECT_HOME}/${project}"
        cd .
    else
        mkproject "${project}"
    fi
}

# pip
export PIP_REQUIRE_VIRTUALENV=true
[ -d "${HOME}/.pip/cache" ] && export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"
syspip() { PIP_REQUIRE_VIRTUALENV="" pip "$@"; }
syspip3() { PIP_REQUIRE_VIRTUALENV="" pip3 "$@"; }


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
[ -f "${HOMEBREW_HOME}/etc/bash_completion" ] && source "${HOMEBREW_HOME}/etc/bash_completion"


# EC2
# ===
[ -d "${HOME}/.local/ec2-api-tools" ] && export EC2_HOME="${HOME}/.local/ec2-api-tools"
[ -d "${HOME}/.local/ec2-api-tools" ] && export PATH="${EC2_HOME}/bin:${PATH}"
export EC2_PRIVATE_KEY="~/.ec2/pk.pem"
export EC2_CERT="~/.ec2/cert.pem"
export EC2_URL="ec2.ap-southeast-1.amazonaws.com"


# Powerline
# =========
#_update_ps1() { export PS1="$(~/.powerline-shell.py --mode flat $?) "; }
#[ -x ~/.powerline-shell.py ] && export PROMPT_COMMAND="_update_ps1"


# final export PATH changes
export PATH

