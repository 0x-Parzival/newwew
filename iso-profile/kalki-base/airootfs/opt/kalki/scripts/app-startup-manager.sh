#!/bin/bash
# Kalki OS Application Startup Manager

# Ensure XDG_RUNTIME_DIR is set for systemd user services
if [ -z "${XDG_RUNTIME_DIR}" ]; then
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    if [ ! -d "${XDG_RUNTIME_DIR}" ]; then
        mkdir -p "${XDG_RUNTIME_DIR}"
        chmod 0700 "${XDG_RUNTIME_DIR}"
    fi
fi

# Create necessary directories
KALKI_HOME="${HOME}/.kalki"
APPS_DIR="${KALKI_HOME}/apps"
DATA_DIR="${KALKI_HOME}/data"
LOGS_DIR="${KALKI_HOME}/logs"

mkdir -p "${APPS_DIR}" "${DATA_DIR}" "${LOGS_DIR}"
mkdir -p "${DATA_DIR}/documents" "${DATA_DIR}/designs" "${DATA_DIR}/schedules" "${DATA_DIR}/app-cache"

# Set up logging
LOG_FILE="${LOGS_DIR}/app-manager-$(date +%Y%m%d).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "=== Starting Kalki OS Application Manager $(date) ==="

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if applications need initialization
if [[ ! -f "${KALKI_HOME}/apps-initialized" ]]; then
    log "🕉️ First-time application setup..."
    
    # Create user application directories
    mkdir -p "${APPS_DIR}/bunniwrite" "${APPS_DIR}/designdeva" "${APPS_DIR}/roostytime" "${APPS_DIR}/appmantra"
    
    # Copy default templates if they exist
    if [[ -d "/opt/kalki/apps/bunniwrite/templates" ]]; then
        log "Copying BunniWrite templates..."
        cp -r /opt/kalki/apps/bunniwrite/templates/* "${DATA_DIR}/documents/" 2>/dev/null || true
    fi
    
    if [[ -d "/opt/kalki/apps/designdeva/templates" ]]; then
        log "Copying DesignDeva templates..."
        cp -r /opt/kalki/apps/designdeva/templates/* "${DATA_DIR}/designs/" 2>/dev/null || true
    fi
    
    # Set up default configuration files
    cat > "${KALKI_HOME}/app-settings.json" << EOF
{
    "version": 1,
    "apps": {
        "bunniwrite": {
            "autoSave": true,
            "darkMode": true,
            "fontSize": 14
        },
        "designdeva": {
            "theme": "dark",
            "autoSave": true,
            "recentProjects": []
        },
        "roostytime": {
            "notifications": true,
            "startOnLogin": true,
            "workHours": {
                "start": "09:00",
                "end": "17:00"
            }
        },
        "appmantra": {
            "autoUpdate": true,
            "checkFrequency": "daily",
            "lastUpdateCheck": ""
        }
    },
    "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    # Set appropriate permissions
    chmod -R 750 "${KALKI_HOME}"
    chown -R $(id -u):$(id -g) "${KALKI_HOME}"
    
    # Mark as initialized
    touch "${KALKI_HOME}/apps-initialized"
    log "✅ Application setup complete"
fi

# Function to check if an application is running
is_app_running() {
    local app_name=$1
    pgrep -f "python3 .*${app_name}" >/dev/null 2>&1
    return $?
}

# Function to start an application if not running
start_application() {
    local app_name=$1
    local app_path=""
    
    case "${app_name}" in
        "bunniwrite")
            app_path="/opt/kalki/apps/bunniwrite/src/bunniwrite.py"
            ;;
        "designdeva")
            app_path="/opt/kalki/apps/designdeva/src/designdeva.py"
            ;;
        "roostytime")
            app_path="/opt/kalki/apps/roostytime/src/roostytime.py"
            ;;
        "appmantra")
            app_path="/opt/kalki/apps/appmantra/src/appmantra.py"
            ;;
        *)
            log "❌ Unknown application: ${app_name}"
            return 1
            ;;
    esac
    
    if [ ! -f "${app_path}" ]; then
        log "⚠️ Application not found: ${app_path}"
        return 1
    fi
    
    if ! is_app_running "${app_name}"; then
        log "🚀 Starting ${app_name}..."
        nohup python3 "${app_path}" >/dev/null 2>&1 &
    else
        log "ℹ️ ${app_name} is already running"
    fi
}

# Main monitoring loop
log "Starting application monitoring..."
while true; do
    # Check if any applications need to be restarted
    for app in bunniwrite designdeva roostytime appmantra; do
        if ! is_app_running "${app}"; then
            log "⚠️ ${app} is not running, attempting to start..."
            start_application "${app}" || log "❌ Failed to start ${app}"
        fi
    done
    
    # Sleep for a while before checking again
    sleep 300  # Check every 5 minutes
    
    # Rotate logs if needed
    if [ $(date +%d) -ne $(stat -c %y "${LOG_FILE}" | cut -d' ' -f1 | cut -d'-' -f3) ]; then
        mv "${LOG_FILE}" "${LOG_FILE}.$(date -d yesterday +%Y%m%d)"
        exec > >(tee -a "${LOG_FILE}") 2>&1
        log "Rotated log file"
    fi
done
