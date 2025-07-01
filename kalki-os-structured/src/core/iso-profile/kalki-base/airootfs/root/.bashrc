# Root shell configuration for Kalki OS

# Custom root prompt (red to indicate root)
PS1='🕉️ \[\033[01;31m\]\u@kalki\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '

# Safety features for root
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Clear screen and show system info on login
clear
echo "🛡️  You are logged in as root"
echo "🔒 Be mindful of your actions"
echo ""

# Source global bashrc if it exists
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Add local binaries to PATH
if [ -d "/root/.local/bin" ]; then
    export PATH="/root/.local/bin:$PATH"
fi

# Enhanced directory listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Color support for various commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
