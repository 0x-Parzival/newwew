#!/bin/bash
# app-startup-manager.sh: Unified launcher and aliases for dharmic apps

case "$1" in
  bunni)
    exec /opt/kalki/apps/bunniwrite/start.sh
    ;;
  design)
    exec /opt/kalki/apps/designdeva/start.sh
    ;;
  time|roostytime)
    exec /opt/kalki/apps/roostytime/start.sh
    ;;
  store|appstore|appmantra)
    exec /opt/kalki/apps/appmantra/start.sh
    ;;
  list)
    echo "Available apps: bunni, design, roostytime, appstore"
    ;;
  *)
    echo "Usage: kalki-apps [bunni|design|time|store|list]"
    ;;
esac 