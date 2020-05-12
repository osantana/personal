#!/bin/sh

# Speedup terminal opening (maintenance operations)
#   sudo rm -f /private/var/log/asl/*.asl /etc/paths.d/*
#   > /etc/paths
#   Use bash -l on login command in Terminal settings

case $- in
    *i*) ;;
      *) return;;
esac

# Terminal
shopt -s checkwinsize

if [ "$(uname)" == "Darwin" ]; then
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

# Prompt
powerline="${HOME}/Work/personal/powerline-shell/.venv/bin/powerline-shell"
function _update_ps1() {
    PS1="$(${powerline} $? 2> /dev/null)"
}

if [ -x "${powerline}" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
else
    case "$TERM" in
        xterm-color|*-256color) color_prompt=yes;;
    esac

    if [ "$color_prompt" = yes ]; then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='\u@\h:\w\$ '
    fi
    unset color_prompt
    echo "You could install powerline-shell in ${powerline}" >&2
fi

# History
# =======
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000


# Aliases && Default
# ==================
alias mv="mv -i"
alias cp="cp -i"

export EDITOR=vim


# Basic PATH (speedup path_helper)
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

if [ "$(uname)" == "Darwin" ]; then
    [ -d "/opt/X11/bin" ] && PATH="${PATH}:/opt/X11/bin"
    [ -d "/usr/texbin" ] && PATH="${PATH}:/usr/local/MacGPG2/bin"
    [ -d "/usr/local/MacGPG2/bin" ] && PATH="${PATH}:/usr/local/MacGPG2/bin"
fi

# github
if [ -f "${HOME}/.githubrc" ]; then
	export GITHUB_TOKEN=$(sed -n '/^\s*token/s/.*=//p' ~/.githubrc)
fi

# Homebrew
if [ "$(uname)" == "Darwin" ]; then
    export HOMEBREW_HOME="/usr/local"
    PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin:$PATH"
fi

[ -f "${HOME}/.secrets/misc/github.token" -a -f "${HOME}/.githubrc" ] && export HOMEBREW_GITHUB_API_TOKEN="$(sed -n '/^\s*token/s/.*=//p' "${HOME}/.githubrc")"

# Kegs
[ -d "${HOMEBREW_HOME}/opt/gettext/bin" ] && PATH="${HOMEBREW_HOME}/opt/gettext/bin:${PATH}"
[ -d "${HOMEBREW_HOME}/opt/tcl-tk/bin" ] && PATH="${HOMEBREW_HOME}/opt/tcl-tk/bin:${PATH}"
[ -d "${HOMEBREW_HOME}/opt/sqlite/bin" ] && PATH="${HOMEBREW_HOME}/opt/sqlite/bin:${PATH}"


# OpenSSL Keg
OPENSSL_ROOTDIR="${HOMEBREW_HOME}/opt/openssl@1.1"
if [ -d "${OPENSSL_ROOTDIR}" ]; then
	PATH="/usr/local/opt/openssl@1.1/bin:${PATH}"
	DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:+${DYLD_LIBRARY_PATH}:}${OPENSSL_ROOTDIR}/lib"
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH+${PKG_CONFIG_PATH}:}${OPENSSL_ROOTDIR}/lib/pkgconfig"
	LDFLAGS="${LDFLAGS} -L${OPENSSL_ROOTDIR}/lib"
	CPPFLAGS="${CPPFLAGS} -I${OPENSSL_ROOTDIR}/include"
fi

# Zlib Keg
ZLIB_ROOTDIR="${HOMEBREW_HOME}/opt/zlib"
if [ -d "${ZLIB_ROOTDIR}" ]; then
	LDFLAGS="${LDFLAGS}   -L${ZLIB_ROOTDIR}/lib"
	CPPFLAGS="${CPPFLAGS} -I${ZLIB_ROOTDIR}/include"
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH+${PKG_CONFIG_PATH}:}${ZLIB_ROOTDIR}/lib/pkgconfig"
fi


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
if [ -x "${HOMEBREW_HOME}/bin/virtualenvwrapper.sh" ]; then
    export VIRTUALENVWRAPPER_PYTHON="$(which python3)"
    export VIRTUALENVWRAPPER_SCRIPT="${HOMEBREW_HOME}/bin/virtualenvwrapper.sh"
    source "${HOMEBREW_HOME}/bin/virtualenvwrapper_lazy.sh"
fi
p() { workon $(workon | sed -n "/^$(echo $1 | sed 's,/,,').*/p" | sort -u | head -1); }
c() { cdproject $*; }

newproject() {
    project="$1"
    pyver="${2:-3.5}"
    echo "Python: $(which python${pyver})"
    [ -d "${WORKON_HOME}/${project}" ] && rm -rf "${WORKON_HOME}/${project}"
    if [ -d "${PROJECT_HOME}/${project}" ]; then
        mv "${PROJECT_HOME}/${project}" "${PROJECT_HOME}/${project}.tmp"
	mkproject -p "$(which python${pyver})" "${project}"
        rm -rf "${PROJECT_HOME}/${project}"
        mv "${PROJECT_HOME}/${project}.tmp" "${PROJECT_HOME}/${project}"
        cd .
    else
	mkproject -p "$(which python${pyver})" "${project}"
    fi
}

# pip
[ -d "${HOME}/.pip/cache" ] && export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"
syspip() { PIP_REQUIRE_VIRTUALENV="" pip2 "$@"; }
syspip3() { PIP_REQUIRE_VIRTUALENV="" pip3 "$@"; }

# pyenv
if [ -d "${HOME}/.pyenv" ]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:$PATH"
else
    export PYENV_ROOT=/usr/local/var/pyenv
    export PATH="/usr/local/var/pyenv/bin:$PATH"
fi
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi


# Ruby
[ -d "${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin" ] && PATH="${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin:$PATH"
[ -d "${HOME}/.gem" ] && export GEM_HOME="${HOME}/.gem"
[ -d "${GEM_HOME}/ruby/2.5.0/bin" ] && PATH="${GEM_HOME}/ruby/2.5.0/bin:${PATH}"
[ -d "/usr/local/opt/ruby/bin" ] && PATH="/usr/local/opt/ruby/bin:${PATH}"
[ -d "/usr/local/lib/ruby/gems/2.6.0/bin" ] && PATH="/usr/local/lib/ruby/gems/2.6.0/bin:${PATH}"

# Java
[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"
[ -d "${HOME}/.local/jre" ] && export JAVA_HOME="${HOME}/.local/jre"
PATH="${JAVA_HOME}/bin:${PATH}"

# Go
[ -d "${HOME}/.go" ] && export GOPATH="${HOME}/.go"
[ -d "/usr/local/opt/go/libexec" ] && export GOROOT=/usr/local/opt/go/libexec
PATH="${GOPATH}/bin:${GOROOT}/bin:${PATH}"

# Local
# =====
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"


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



# AWS
# ===
export EC2_PRIVATE_KEY="~/.ec2/pk.pem"
export EC2_CERT="~/.ec2/cert.pem"
export AWS_PROFILE="osvaldo-olist"

# Android
[ -d "${HOME}/.android/sdk" ] && export ANDROID_HOME="${HOME}/.android/sdk"
[ -d "${ANDROID_HOME}/tools" ] && PATH="${ANDROID_HOME}/tools:${PATH}"
[ -d "${ANDROID_HOME}/tools/bin" ] && PATH="${ANDROID_HOME}/tools/bin:${PATH}"
[ -d "${ANDROID_HOME}/platform-tools" ] && PATH="${ANDROID_HOME}/platform-tools:${PATH}"

# Misc
# ====

# gpg aliases
[ -d "${HOMEBREW_HOME}/opt/gnupg/libexec/gpgbin" ] && PATH="${HOMEBREW_HOME}/opt/gnupg/libexec/gpgbin:${PATH}"

# qt
PATH="/usr/local/opt/qt/bin:$PATH"

# heroku
PATH="/usr/local/heroku/bin:$PATH"

if [ -f "${HOME}/.herokurc" ]; then
    export HEROKU_API_KEY=$(sed -n '/^\s*token/s/.*=//p' ~/.herokurc)
fi

# pyenv
PATH="/home/osantana/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper_lazy

# final export PATH changes
export PATH LDFLAGS CPPFLAGS PKG_CONFIG_PATH DYLD_LIBRARY_PATH
