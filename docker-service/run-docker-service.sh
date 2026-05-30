#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Docker Service — Launch script
# Usage: ./run.sh
# ─────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_FILE="${SCRIPT_DIR}/docker-service.py"
ALLOWED_DIRS_FILE="${SCRIPT_DIR}/allowed_dirs.txt"
LOG_FILE="${SCRIPT_DIR}/docker-service.log"
PID_FILE="${SCRIPT_DIR}/docker-service.pid"
PORT=18765

# ── Checks ──────────────────────────────────────────────────

if [ ! -f "$PYTHON_FILE" ]; then
  echo "ERROR: docker-service.py not found in $SCRIPT_DIR"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 not found"
  exit 1
fi

# ── Whitelist dir ───────────────────────────────────────────

mkdir -p "${SCRIPT_DIR}"
if [ ! -f "$ALLOWED_DIRS_FILE" ]; then
  echo "# Allowed directories for docker-service" > "$ALLOWED_DIRS_FILE"
  echo "# Add one path per line, e.g. /opt/data/hermes-workspace" >> "$ALLOWED_DIRS_FILE"
  echo "NOTE: created empty $ALLOWED_DIRS_FILE — add your paths before starting"
fi

# ── Install deps ─────────────────────────────────────────────

pip install fastapi uvicorn pydantic --quiet 2>/dev/null || \
  pip3 install fastapi uvicorn pydantic --quiet 2>/dev/null

# ── Status ───────────────────────────────────────────────────

status() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      echo "Running (PID $PID)"
      curl -s "http://localhost:${PORT}/health" 2>/dev/null && echo "" || true
      return 0
    fi
  fi
  echo "Stopped"
  return 1
}

# ── Start ────────────────────────────────────────────────────

start() {
  if status &>/dev/null; then
    echo "Already running"
    return 0
  fi

  echo "Starting docker-service..."
  nohup python3 "$PYTHON_FILE" >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  sleep 2

  if status &>/dev/null; then
    echo "Started on port $PORT"
  else
    echo "Failed — check $LOG_FILE"
    return 1
  fi
}

# ── Stop ─────────────────────────────────────────────────────

stop() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      rm -f "$PID_FILE"
      echo "Stopped"
    else
      rm -f "$PID_FILE"
      echo "Not running"
    fi
  else
    echo "Not running"
  fi
}

# ── Restart ───────────────────────────────────────────────────

restart() {
  stop
  sleep 1
  start
}

# ── Logs ──────────────────────────────────────────────────────

logs() {
  if [ -f "$LOG_FILE" ]; then
    tail -f "$LOG_FILE"
  else
    echo "No log file found"
  fi
}

# ── CLI ───────────────────────────────────────────────────────

case "${1:-start}" in
  start)   start ;;
  stop)    stop ;;
  restart) restart ;;
  status)  status ;;
  logs)    logs ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs}"
    exit 1
    ;;
esac