# Kalki OS Default Shell Configuration

# Custom prompt with dharmic elements
PS1='🕉️ \[\033[01;35m\]\u@kalki\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '

# Kalki OS aliases
alias krix='krix-term'
alias omnet='systemctl status omnet'
alias dharma='echo "🌌 May your code be mindful and your processes be at peace"'

# Welcome message
echo "🕉️ Welcome to Kalki OS - Dharmic Computing Platform"
echo "Type 'krix' to enter the sentient terminal"

# Source global bashrc if it exists
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Add local binaries to PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Enable color support for various commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Enhanced directory listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safety features
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
