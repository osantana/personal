#!/bin/bash

# =====
# DEBUG
# =====
# set -vx


# ==========
# Basic PATH (speedup path_helper)
# ==========
# WARNING: This section needs to be in the beginning of this file!
OS=linux
[ "$(uname)" == "Darwin" ] && OS=mac

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
if [ "${OS}" == "mac" ]; then
    [ -d "/opt/X11/bin" ] && PATH="${PATH}:/opt/X11/bin"
fi

# =========
# Utilities
# =========
ensure() {
    bin="$1"

    if which $bin > /dev/null; then
        return
    fi

    if [ -x "${bin}" ]; then
        return
    fi

    installation="$2"
    if [ "${OS}" == "linux" -a "$3" ]; then
        installation="$3"
    fi

    echo "Installing $(basename $bin) with command: $installation..."
    eval "${installation}"
}


# =================
# Terminal & Editor
# =================
shopt -s checkwinsize
shopt -s histappend
alias mv="mv -i"
alias cp="cp -i"
export EDITOR=vim
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# Warp Terminal
if [ "${TERM_PROGRAM}" == "WarpTerminal" ]; then
    export SPACESHIP_PROMPT_ASYNC=false
    export SPACESHIP_PROMPT_SEPARATE_LINE=false
    export SPACESHIP_CHAR_SYMBOL=""
fi

# color
if [ "$(uname)" == "Darwin" ]; then
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
    export CLICOLOR=1
    export LSCOLORS=exgxfxDxcxDxDxCxCxHbHb
    alias ls="ls -G"
else
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
        alias ls="ls --color=auto"
    fi
fi


# ========
# Homebrew
# ========
if [ "$(uname)" == "Darwin" ]; then
    export HOMEBREW_HOME="/opt/homebrew"
    export HOMEBREW_PREFIX="${HOMEBREW_HOME}"
    export HOMEBREW_CELLAR="${HOMEBREW_HOME}/Cellar"
    export HOMEBREW_REPOSITORY="${HOMEBREW_HOME}"
    export MANPATH="${HOMEBREW_HOME}/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="${HOMEBREW_HOME}/share/info:${INFOPATH:-}"
    PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin${PATH+:$PATH}"
    if [ -f "${HOME}/.secrets/misc/github.token" -a -f "${HOME}/.githubrc" ]; then
        export HOMEBREW_GITHUB_API_TOKEN="$(sed -n '/^\s*token/s/.*=//p' "${HOME}/.githubrc")"
    fi
fi

# Kegs
[ -d "${HOMEBREW_HOME}/opt/gettext/bin" ] && PATH="${HOMEBREW_HOME}/opt/gettext/bin:${PATH}"
[ -d "${HOMEBREW_HOME}/opt/tcl-tk/bin" ] && PATH="${HOMEBREW_HOME}/opt/tcl-tk/bin:${PATH}"
[ -d "${HOMEBREW_HOME}/opt/sqlite/bin" ] && PATH="${HOMEBREW_HOME}/opt/sqlite/bin:${PATH}"
[ -d "${HOMEBREW_HOME}/opt/bzip2/bin" ] && PATH="${HOMEBREW_HOME}/opt/bzip2/bin:${PATH}"

OPENSSL_ROOTDIR="${HOMEBREW_HOME}/opt/openssl@1.1"
if [ -d "${OPENSSL_ROOTDIR}" ]; then
    PATH="${HOMEBREW_PREFIX}/opt/openssl@1.1/bin:${PATH}"
    DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:+${DYLD_LIBRARY_PATH}:}${OPENSSL_ROOTDIR}/lib"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH+${PKG_CONFIG_PATH}:}${OPENSSL_ROOTDIR}/lib/pkgconfig"
    LDFLAGS="${LDFLAGS} -L${OPENSSL_ROOTDIR}/lib"
    CPPFLAGS="${CPPFLAGS} -I${OPENSSL_ROOTDIR}/include"
fi

ZLIB_ROOTDIR="${HOMEBREW_HOME}/opt/zlib"
if [ -d "${ZLIB_ROOTDIR}" ]; then
    LDFLAGS="${LDFLAGS}   -L${ZLIB_ROOTDIR}/lib"
    CPPFLAGS="${CPPFLAGS} -I${ZLIB_ROOTDIR}/include"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH+${PKG_CONFIG_PATH}:}${ZLIB_ROOTDIR}/lib/pkgconfig"
fi


# ======
# Prompt
# ======

ensure "starship" \
       "brew install starship" \
       "curl -fsSL https://starship.rs/install.sh | bash"

eval "$(starship init bash)"


# =====================
# Languages & Platforms
# =====================

# Python
# ------
[ -f "${HOME}/.pystartup.py" ] && export PYTHONSTARTUP="${HOME}/.pystartup.py"

# pyenv
ensure "pyenv" \
       "brew install pyenv pyenv-ccache pyenv-pip-migrate pyenv-virtualenv pyenv-virtualenvwrapper" \
       "curl https://pyenv.run | bash"

if [ -d "${HOME}/.pyenv" ]; then
    export PYENV_ROOT="${HOME}/.pyenv"
else
    export PYENV_ROOT=${HOMEBREW_PREFIX}/var/pyenv
fi

PATH="${PYENV_ROOT}/bin:$PATH"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper_lazy

# virtualenvwrapper
[ -d "${HOME}/Work" ] && export PROJECT_HOME="${HOME}/Work"
[ -d "${HOME}/.virtualenvs" ] && export WORKON_HOME="${HOME}/.virtualenvs"

p() {
    workon $(workon | sed -n "/^$(echo $1 | sed 's,/,,').*/p" | sort -u | head -1);
    [ -f "${VIRTUAL_ENV}/.project" ] || echo "${PROJECT_HOME}/$(basename ${VIRTUAL_ENV})" > "${VIRTUAL_ENV}/.project"
    c
}
c() {
    if [ -z "${VIRTUAL_ENV}" ]; then
        return
    fi
    [ -f "${VIRTUAL_ENV}/.project" ] || echo "${PROJECT_HOME}/$(basename ${VIRTUAL_ENV})" > "${VIRTUAL_ENV}/.project"
    cdproject $*;
}

# pip
[ -d "${HOME}/.pip/cache" ] && export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"

# poetry
ensure "${HOME}/.local/bin/poetry" \
       "curl -sSL https://install.python-poetry.org | python3 -"

upoetry() {
    rm -f poetry.lock && poetry update && git add poetry.lock
}

# uppy
uppy() {
    pip install -U setuptools
    pip install -U pip
    pip install -U wheel virtualenv virtualenvwrapper
    poetry self update
}

# Ruby
# ----
# TODO: adopt nvm/pyenv-like tool for Ruby

# Java
# ----
JAVA_VM="jdk-20.jdk"
if [ -d "/Library/Java/JavaVirtualMachines/${JAVA_VM}/Contents/Home" ]; then
    JAVA_HOME="/Library/Java/JavaVirtualMachines/${JAVA_HOME}/Contents/Home"
elif [ -d "/Library/Java/Home" ]; then
    JAVA_HOME="/Library/Java/Home"
elif [ -d "${HOME}/.local/jre" ]; then
    JAVA_HOME="${HOME}/.local/jre"
elif [ -d "${HOMEBREW_HOME}/opt/openjdk" ]; then
    JAVA_HOME="${HOMEBREW_HOME}/opt/openjdk"
fi
export JAVA_HOME JAVA_VM

PATH="${JAVA_HOME}/bin:${PATH}"

# Android
# -------
[ -d "${HOME}/.android/sdk" ] && export ANDROID_HOME="${HOME}/.android/sdk"
[ -d "${ANDROID_HOME}/tools" ] && PATH="${ANDROID_HOME}/tools:${PATH}"
[ -d "${ANDROID_HOME}/tools/bin" ] && PATH="${ANDROID_HOME}/tools/bin:${PATH}"
[ -d "${ANDROID_HOME}/platform-tools" ] && PATH="${ANDROID_HOME}/platform-tools:${PATH}"

# Go
# --


ensure "go" \
       "brew install go" \
       "sudo apt install golang-go"

# gopath
export GOPATH="${HOME}/.go"
mkdir -p "${GOPATH}"

# goroot
if [ -d "${HOMEBREW_PREFIX}/opt/go/libexec" ]; then
    export GOROOT="${HOMEBREW_PREFIX}/opt/go/libexec"
fi

PATH="${GOPATH}/bin:${GOROOT}/bin:${PATH}"


# JS
# --
export NVM_DIR="${HOME}/.nvm"
[ -s "${HOMEBREW_HOME}/opt/nvm/nvm.sh" ] && source "${HOMEBREW_HOME}/opt/nvm/nvm.sh"
[ -s "${HOMEBREW_HOME}/opt/nvm/etc/bash_completion.d/nvm" ] && source "${HOMEBREW_HOME}/opt/nvm/etc/bash_completion.d/nvm"

# LLVM
# ----
[ -d "${HOMEBREW_HOME}/opt/llvm/bin" ] && PATH="${HOMEBREW_HOME}/opt/llvm/bin:${PATH}"


# ===========
# Completions
# ===========
if [ -f "${HOME}/.bash_completion" ]; then
    source "${HOME}/.bash_completion"
else
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi


# ========
# Services
# ========

# heroku
# TODO: add and install heroku-cli
PATH="${HOMEBREW_PREFIX}/heroku/bin:${PATH}"

if [ -f "${HOME}/.herokurc" ]; then
    export HEROKU_API_KEY=$(sed -n '/^\s*token/s/.*=//p' ~/.herokurc)
fi

# github
# TODO: add and install gh-cli
if [ -f "${HOME}/.githubrc" ]; then
    export GITHUB_TOKEN=$(sed -n '/^\s*token/s/.*=//p' ~/.githubrc)
fi

# 1password
# TODO: install 1password cli
source "${HOME}/.config/op/plugins.sh"


# ====
# Misc
# ====

# gpg aliases
if [ -d "${HOMEBREW_HOME}/opt/gnupg/libexec/gpgbin" ]; then
    PATH="${HOMEBREW_HOME}/opt/gnupg/libexec/gpgbin:${PATH}"
fi

# curl issue (https://security.stackexchange.com/questions/232445/https-connection-to-specific-sites-fail-with-curl-on-macos)
export CURL_SSL_BACKEND="secure-transport"


# ========================
# Final PATH consolidation
# ========================
# WARNING: This section must be at the end of this file
if [ -d "${HOME}/.local/bin" ]; then
   PATH="${HOME}/.local/bin:${PATH}"
fi
export PATH LDFLAGS CPPFLAGS PKG_CONFIG_PATH DYLD_LIBRARY_PATH

# vim:ts=4:sw=4:tw=80:et:ai:si
