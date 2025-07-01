#!/bin/bash
# report-build-metrics.sh: Report build performance metrics for Kalki OS
set -euo pipefail

START_TIME=$(date +%s)
LOG_FILE="/tmp/build-metrics.log"
echo "[INFO] Build started at $(date)" | tee "$LOG_FILE"

# Usage: source this script at the start, call report_build_metrics_end at the end
report_build_metrics_end() {
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  echo "[INFO] Build ended at $(date)" | tee -a "$LOG_FILE"
  echo "[INFO] Total build duration: $DURATION seconds" | tee -a "$LOG_FILE"
  if command -v /usr/bin/time &>/dev/null; then
    echo "[INFO] Peak resource usage (see below):" | tee -a "$LOG_FILE"
    /usr/bin/time -v true 2>&1 | tee -a "$LOG_FILE"
  else
    echo "[WARN] /usr/bin/time not available. Skipping resource usage report." | tee -a "$LOG_FILE"
  fi
} 