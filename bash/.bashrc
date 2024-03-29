echo "bashrc: starting..."

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=20000

# don't wait until the shell is closing to add to the history
# (allows accessing history of open shells from other open shells)
# http://mywiki.wooledge.org/BashFAQ/088
PROMPT_COMMAND="history -a; history -r"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# https://github.com/magicmonty/bash-git-prompt
#GIT_PROMPT_ONLY_IN_REPO=1
#GIT_PROMPT_THEME=Evermeet
#source ~/.bash/bash-git-prompt/gitprompt.sh

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# https://github.com/wting/autojump
#. /usr/share/autojump/autojump.sh || echo "autojump not installed"

# shows run time of last command. must be the last command in `PROMPT_COMMAND`.
#. ~/dotfiles/runtimeshow.sh

# if [ "$color_prompt" = yes ]; then
#     PS1='[last: ${timer_show}s] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

echo "bashrc: loading nvm..."

# export NVM_DIR="/home/rob/.nvm"
#export NVM_DIR="$HOME/.nvm"
#
#[ -s "$NVM_DIR/nvm.sh" ] && time \. "$NVM_DIR/nvm.sh"  # This loads nvm
#

#alias vim=nvim

#export VISUAL=nvim
#export EDITOR="$VISUAL"

#echo "bashrc: checking ssh agent..."

# http://askubuntu.com/a/634573/340840
# Set up ssh-agent
# TODO: find a way to not break NixOS, but still do the thing on Ubuntu
#SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initializing new SSH agent..."
    touch $SSH_ENV
    chmod 600 "${SSH_ENV}"
    ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    ssh-add
}

# Source SSH settings, if applicable
#if [ -f "${SSH_ENV}" ]; then
#    . "${SSH_ENV}" > /dev/null
#    kill -0 $SSH_AGENT_PID 2>/dev/null || {
#        start_agent
#    }
#else
#    start_agent
#fi

# https://gist.github.com/raine/f452cf1588bc7b78d04a
alias bunyan-heroku="sed -u 's/.*app\[web\..*\]\: //' | bunyan" 


echo "bashrc: done"

#cd ~

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias gs="git status"

export MANWIDTH=80

alias open='cmd.exe /c start ""'

# improved tab completion
# via https://stackoverflow.com/a/48514114/2014893

# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB':menu-complete

# Display a list of the matching files
bind "set show-all-if-ambiguous on"

# Perform partial completion on the first Tab press,
# only start cycling full results on the second Tab press
bind "set menu-complete-display-prefix on"

# Workaround a locale bug in NixOS
# https://unix.stackexchange.com/a/243189/89024
#export LOCALE_ARCHIVE="$(nix-env --installed --no-name --out-path --query glibc-locales)/lib/locale/locale-archive"
#export LANG=en_US.UTF-8
#export LOCALE_ARCHIVE="$(readlink ~/.nix-profile/lib/locale)/locale-archive"

# Hook up direnv, for automatic isolated dev environments
eval "$(direnv hook bash)"


# quick way to see if the given local branch has already been merged (or
# rebased) into the "main" branch
#
# Usage:
#    isMerged branch-i-want-to-check
#
# Defaults to the current branch if none is specified.
# Assumes the remote is named `origin`.
function isMerged() {
    echo "If a line starts with +, it's not in the main branch."
    echo "If a line starts with =, it's already in the main branch."
    checking=${1:-$(git symbolic-ref --short HEAD)}
    main="$(git remote show origin | grep "HEAD branch" | sed 's/.*: //')"
    cmd="git log --oneline --cherry origin/$main...$checking"
    echo "$cmd" && $cmd
}

# allow fuzzy search in Ctrl+R history
# https://nixos.wiki/wiki/Fzf
if command -v fzf-share >/dev/null; then
  source "$(fzf-share)/key-bindings.bash"
  source "$(fzf-share)/completion.bash"
  alias fzff="fzf --preview 'bat --color=always {}'"
fi


source /home/rkb/.config/broot/launcher/bash/br

eval "$(zoxide init bash)"

