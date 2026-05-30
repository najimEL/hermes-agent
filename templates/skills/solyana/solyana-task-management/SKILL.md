---
name: solyana-task-management
description: Système de gestion de tasks et kanban pour SOLYANA
category: solyana
created: 2025-05-25
tags: [tasks, kanban, solyana, backlog]
---

# SOLYANA Task Management

## 🎯 Rôle

Je gère les tasks de EL PATRON via le système kanban/backlog.

---

## 📋 Les 6 statuts

| Status | Signification |-action |
|--------|--------------|---------|
| **backlog** | En attente, pas prêt | Move to todo quand EL PATRON décide |
| **todo** | Prêt à démarrer | Move to in-progress quand je commence |
| **in-progress** | En cours | Move to review quand prêt pour validation |
| **review** | En validation | Move to done si validé, blocked si problème |
| **done** | Terminé | Garder en archive |
| **blocked** | Bloqué | Signaler à EL PATRON |

---

## 🏢 Entités assignables

- `LMNP` — pour la location meublée
- `SASU` — pour la SASU prestations IT/IA/DevOps
- `MICRO` — pour la micro-entreprise consultant DevOps
- `SOLYANA` — pour la structure générale / multi-entité

---

## ⚡ Commandes EL PATRON

### Ajouter une task

```
@ANA add task: [titre] for [entité] priority [high/medium/low]
```

**Exemple :**
```
@ANA add task: Configurer backup auto for SOLYANA priority high
```

**Règles :**
- Je génère un task-id unique (format: `T-XXX`)
- entity = une des 4 entités (défaut: SOLYANA)
- priority = high/medium/low (défaut: medium)
- Je l'ajoute dans `tasks.json` ET dans `backlog.md`

---

### Changer statut

```
@ANA move [task-id] to [status]
@ANA move T-001 to done
```

**Règles :**
- Je mets à jour `tasks.json`
- Je reconstruis `kanban.md` et `backlog.md`

---

### Lister les tasks

```
@ANA kanban       → affiche le board
@ANA backlog      → affiche les tasks en attente
@ANA tasks [filtre] → affiche les tasks (filtre: all, todo, done, etc.)
```

---

### Détail d'une task

```
@ANA task T-001   → affiche le détail de la task
```

---

## 🔧 Procédure interne

### ADD TASK
1. Générer ID unique (T-XXX, incrémental)
2. Lire `tasks.json`
3. Ajouter task avec `{id, title, entity, priority, status: backlog, created: date}`
4. Écrire `tasks.json`
5. Réécrire `backlog.md` depuis `tasks.json`
6. Réécrire `kanban.md` depuis `tasks.json`

### MOVE TASK
1. Lire `tasks.json`
2. Trouver la task par ID
3. Vérifier que le nouveau statut est valide
4. Mettre à jour le statut + updated: date
5. Écrire `tasks.json`
6. Réécrire `kanban.md` et `backlog.md`

### REBUILD KANBAN/BACKLOG
1. Lire `tasks.json`
2. Reconstruire `kanban.md` table par statut
3. Reconstruire `backlog.md` groupé par priorité

---

## 📁 Fichiers gérés

```
/opt/data/solyana/backlog/
├── tasks.json     ← source de vérité
├── kanban.md      ← board visuel
└── backlog.md     ← tasks en attente
```

---

## ⚠️ Règles importantes

- **EL PATRON ne me demande PAS de créer des tasks pour lui** (il les ajoute directement)
- Je peux proposer des tasks si je repère un besoin (ex: "il faudrait suivre X")
- Si une task est bloquée → je signale immédiatement à EL PATRON
- Les tasks DONE restent dans tasks.json (archive) mais n'apparaissent plus dans kanban actif

---

## 🎨 Format d'affichage Kanban (Telegram-compatible)

```
📋 **SOLYANA KANBAN**

🟡 BACKLOG:
  • T-001 — Whisper STT [SOLYANA]

⬜ TODO: —
🔵 IN PROGRESS: —
🟢 REVIEW: —
✅ DONE: —
🔴 BLOCKED: —
```

**Règles :**
- Emoji natifs Telegram (pas de ASCII art)
- Pas de tableaux avec pipes
- Tasks groupées par statut avec bullet points
- Priorité + ID visible
- Un seul message par board

### Format Task Detail
```
🔍 **T-001**
📌 Whisper STT pour vocal TG
🏢 SOLYANA | 🟡 Medium | backlog
📅 2025-05-25
📝 Notes: Whisper local host:5001, tester host.docker.internal
```

---

## 📌 Notes

- Ce skill s'intègre avec `solyana-backup-system` (les tasks de backup sont pour SOLYANA)
- Le fichier `tasks.json` est la seule source de vérité
- `kanban.md` et `backlog.md` sont regénérés après chaque modification