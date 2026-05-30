---
name: solyana-backup-system
description: Système de backup full + delta avec restore pour SOLYANA
category: solyana
created: 2025-05-25
tags: [backup, restore, solyana, critical]
---

# SOLYANA Backup System

## 🎯 Objectif

Backup régulier du contexte SOLYANA pour ne jamais perdre le travail accompli.

---

## 📦 Contenu du backup

```
BACKUP FULL :
  ├── solyana/skills/           ← tous les skills
  ├── solyana/memory/           ← mémoire persistante
  ├── solyana/state/            ← état structure (JSON)
  ├── solyana/config/           ← config (sanitized)
  └── solyana/backlog/          ← tasks + kanban

BACKUP DELTA :
  └── Uniquement les fichiers modifiés depuis dernier FULL
```

---

## 🗂️ Structure des backups

```
~/solyana/backups/
├── full/
│   └── backup-full-YYYY-MM-DD.tar.gz
├── delta/
│   └── backup-delta-YYYY-MM-DD.tar.gz
└── restore-history.txt
```

---

## 🔄 Fréquence

```
FULL  → 1x par semaine (ex: dimanche minuit)
DELTA → 1x par semaine (ex: mercredi minuit)
AUTO  → Cron job 2x/semaine
MANU → Commande dispo anytime
```

---

## 📋 Commandes

### Backup FULL (manuel)

```bash
cd ~/solyana && ./scripts/backup.sh full
```

### Backup DELTA (manuel)

```bash
cd ~/solyana && ./scripts/backup.sh delta
```

### Restore

```bash
cd ~/solyana && ./scripts/restore.sh backup-YYYY-MM-DD.tar.gz
```

### Restore FULL récent (latest)

```bash
cd ~/solyana && ./scripts/restore.sh latest
```

---

## ⚙️ Scripts

| Script | Rôle |
|--------|------|
| `backup.sh` | Génère backup full ou delta |
| `restore.sh` | Restaure depuis un backup |
| `list-backups.sh` | Liste les backups disponibles |

---

## ⚠️ Règles de sécurité

- BACKUP AVANT toute modification majeure (skills, config, state)
- Après RESTORE, vérifier que tout est cohérent
- Tester RESTORE de temps en temps (quarterly)

---

## 🔧 Détails techniques

- Delta via `tar --listed-incremental` ou `rsync --link-dest`
- Timestamp dans nom du fichier
- Rotation : garder 6 FULL, 6 DELTA max
- Restore history tracké dans `restore_history.txt`