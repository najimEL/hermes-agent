#!/bin/bash
# ============================================
# SOLYANA Backup Script
# Usage: ./backup.sh [full|delta]
# ============================================

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLYANA_DIR="$(dirname "$SCRIPTS_DIR")"
BACKUP_DIR="$SOLYANA_DIR/backups"
LOG_FILE="$BACKUP_DIR/backup.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Créer dirs si absent
mkdir -p "$BACKUP_DIR/full" "$BACKUP_DIR/delta"

# Snapshot file pour delta
SNAPSHOT="$BACKUP_DIR/full/snapshot.snar"
SNAPSHOT_PREV="$BACKUP_DIR/full/snapshot.prev"

log "Starting backup: ${1:-full}"

case "${1:-full}" in
    full)
        # Renommer old snapshot en prev (pour référence)
        if [ -f "$SNAPSHOT" ]; then
            cp "$SNAPSHOT" "$SNAPSHOT_PREV"
        fi

        # Générer FULL backup
        BACKUP_FILE="$BACKUP_DIR/full/backup-full-$(date '+%Y-%m-%d').tar.gz"

        tar --czf "$BACKUP_FILE" \
            --listed-incremental="$SNAPSHOT" \
            -C "$SOLYANA_DIR" \
            solyana/skills \
            solyana/memory \
            solyana/state \
            solyana/config \
            solyana/backlog 2>/dev/null || true

        log "Full backup created: $BACKUP_FILE"

        # Nettoyage old backups (garder 6 full)
        cd "$BACKUP_DIR/full"
        ls -t backup-full-*.tar.gz 2>/dev/null | tail -n +7 | xargs -r rm --
        log "Old full backups cleaned (keeping 6)"
        ;;

    delta)
        # Générer DELTA backup ( nécessite snapshot existant )
        if [ ! -f "$SNAPSHOT" ]; then
            error "No snapshot found. Run full backup first."
            exit 1
        fi

        BACKUP_FILE="$BACKUP_DIR/delta/backup-delta-$(date '+%Y-%m-%d').tar.gz"

        tar --czf "$BACKUP_FILE" \
            --listed-incremental="$SNAPSHOT" \
            -C "$SOLYANA_DIR" \
            solyana/skills \
            solyana/memory \
            solyana/state \
            solyana/config \
            solyana/backlog 2>/dev/null || true

        log "Delta backup created: $BACKUP_FILE"

        # Nettoyage old delta (garder 6)
        cd "$BACKUP_DIR/delta"
        ls -t backup-delta-*.tar.gz 2>/dev/null | tail -n +7 | xargs -r rm --
        log "Old delta backups cleaned (keeping 6)"
        ;;

    list)
        echo "=== FULL BACKUPS ==="
        ls -lh "$BACKUP_DIR/full/backup-full-"*.tar.gz 2>/dev/null || echo "None"
        echo ""
        echo "=== DELTA BACKUPS ==="
        ls -lh "$BACKUP_DIR/delta/backup-delta-"*.tar.gz 2>/dev/null || echo "None"
        ;;

    *)
        echo "Usage: $0 [full|delta|list]"
        exit 1
        ;;
esac

log "Backup completed successfully"