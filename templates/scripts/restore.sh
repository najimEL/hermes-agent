#!/bin/bash
# ============================================
# SOLYANA Restore Script
# Usage: ./restore.sh <backup-file.tar.gz>
#        ./restore.sh latest
# ============================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLYANA_DIR="$(dirname "$SCRIPTS_DIR")"
BACKUP_DIR="$SOLYANA_DIR/backups"
RESTORE_HISTORY="$BACKUP_DIR/restore_history.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Vérifier args
if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    echo "       $0 latest"
    echo ""
    echo "Available backups:"
    ls -lh "$BACKUP_DIR/full/backup-full-"*.tar.gz "$BACKUP_DIR/delta/backup-delta-"*.tar.gz 2>/dev/null
    exit 1
fi

# Résoudre latest
if [ "$1" = "latest" ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR/full/backup-full-"*.tar.gz 2>/dev/null | head -1)
    if [ -z "$BACKUP_FILE" ]; then
        error "No full backup found"
        exit 1
    fi
    warn "Using latest full backup: $BACKUP_FILE"
else
    # Vérifier que le fichier existe
    if [ ! -f "$1" ]; then
        # Essayer dans backup dirs
        if [ -f "$BACKUP_DIR/full/$1" ]; then
            BACKUP_FILE="$BACKUP_DIR/full/$1"
        elif [ -f "$BACKUP_DIR/delta/$1" ]; then
            BACKUP_FILE="$BACKUP_DIR/delta/$1"
        else
            error "Backup not found: $1"
            exit 1
        fi
    else
        BACKUP_FILE="$1"
    fi
fi

log "Restoring from: $BACKUP_FILE"

# Demander confirmation
warn "This will OVERWRITE current solyana directory!"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Restore cancelled"
    exit 0
fi

# Backup de secours avant restore
SCRATCH_BACKUP="$BACKUP_DIR/scratch-backup-$(date '+%Y-%m-%d_%H-%M-%S').tar.gz"
log "Creating scratch backup first..."
tar -czf "$SCRATCH_BACKUP" -C "$SOLYANA_DIR" solyana 2>/dev/null || true
log "Scratch backup: $SCRATCH_BACKUP"

# Restore
RESTORE_TARGET="$SOLYANA_DIR/solyana"
rm -rf "$RESTORE_TARGET"
mkdir -p "$RESTORE_TARGET"

tar --xzf "$BACKUP_FILE" -C "$RESTORE_TARGET"

log "Restore completed!"
log "Scratch backup saved at: $SCRATCH_BACKUP"

# Logger restore
echo "$(date '+%Y-%m-%d %H:%M:%S') | $BACKUP_FILE | $SCRATCH_BACKUP" >> "$RESTORE_HISTORY"
log "Restore logged"

log "Done! Please restart Hermes agent to reload context."