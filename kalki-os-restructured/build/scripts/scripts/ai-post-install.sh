# Integrate Agent Zero desktop shortcut (if available)
if [ -f "$(dirname "$0")/install-agent-zero-desktop.sh" ]; then
  bash "$(dirname "$0")/install-agent-zero-desktop.sh"
fi 