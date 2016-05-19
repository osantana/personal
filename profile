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
function _update_ps1() {
    PS1="$(~/Work/personal/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

if [ -d "${HOME}/Work/personal/powerline-shell" ]; then
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


# Homebrew
# ========
if [ "$(uname)" == "Darwin" ]; then
    export HOMEBREW_HOME="/usr/local"
    PATH="${HOMEBREW_HOME}/bin:${HOMEBREW_HOME}/sbin:$PATH"
fi

[ -f "${HOME}/.secrets/misc/github.token" ] && export HOMEBREW_GITHUB_API_TOKEN="$(cat ${HOME}/.secrets/misc/github.token)"

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
export PIP_REQUIRE_VIRTUALENV=true
[ -d "${HOME}/.pip/cache" ] && export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"
syspip() { PIP_REQUIRE_VIRTUALENV="" pip2 "$@"; }
syspip3() { PIP_REQUIRE_VIRTUALENV="" pip3 "$@"; }

# pyenv
which pyenv > /dev/null && eval "$(pyenv init -)"

# Ruby
[ -d "${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin" ] && PATH="${HOMEBREW_HOME}/Cellar/ruby/1.9.3-p362/bin:$PATH"

# Java
[ -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"
[ -d "${HOME}/.local/jre" ] && export JAVA_HOME="${HOME}/.local/jre"
PATH="${JAVA_HOME}/bin:${PATH}"

# Go
[ -d "${HOME}/.go" ] && export GOPATH="${HOME}/.go"
[ -d "/usr/local/opt/go/libexec" ] && export GOROOT=/usr/local/opt/go/libexec
PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

# Local
# =====
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"


# Completions
# ===========
[ -f "${HOMEBREW_HOME}/etc/bash_completion" ] && source "${HOMEBREW_HOME}/etc/bash_completion"


# AWS
# ===
[ -d "${HOME}/.local/ec2-api-tools" ] && export EC2_HOME="${HOME}/.local/ec2-api-tools"
[ -d "${HOME}/.local/ec2-api-tools" ] && export PATH="${EC2_HOME}/bin:${PATH}"
export EC2_PRIVATE_KEY="~/.ec2/pk.pem"
export EC2_CERT="~/.ec2/cert.pem"
export EC2_URL="ec2.ap-southeast-1.amazonaws.com"

# final export PATH changes
export PATH

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
