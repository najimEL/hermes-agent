#!/bin/sh
set -e

# ============================================
# SOLYANA Hermes Agent Startup Script
# ============================================
echo "[Hermes] Starting Hermes Agent..."

# Se place à la racine du projet (au cas où le script est lancé depuis un autre répertoire)
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_DIR
echo "[Hermes] Project Directory: $PROJECT_DIR"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"

# ============================================
# Chargement du fichier .env
# ============================================
if [ -f "$ENV_FILE" ]; then
  echo "[Hermes] Chargement des variables depuis $ENV_FILE"
  set -a  # auto-export toutes les variables définies par source
  . "$ENV_FILE"
  set +a
else
  echo "[ERROR] Fichier $ENV_FILE non trouvé. Impossible de charger les variables d'environnement"
  exit 1
fi

# ============================================
# Génération de API_SERVER_KEY si absente
# ============================================
if [ -z "$API_SERVER_KEY" ]; then
  GENERATED_KEY=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p)
  export API_SERVER_KEY="$GENERATED_KEY"
  echo "API_SERVER_KEY=$API_SERVER_KEY" >> "$ENV_FILE"
  echo "[OK] Clé API générée et ajoutée à $ENV_FILE"
fi

# ============================================
# Vérifications des variables d'environnement
# ============================================
if [ -z "$MINIMAX_API_KEY" ]; then
  echo "[ERROR] MINIMAX_API_KEY n'est pas défini dans $ENV_FILE"
  exit 1
fi
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "[ERROR] TELEGRAM_BOT_TOKEN n'est pas défini dans $ENV_FILE"
  echo "Si vous n'utilisez pas Telegram, définissez une valeur factice"
  exit 1
fi
if [ -z "$TELEGRAM_ALLOWED_USERS" ]; then
  echo "[ERROR] TELEGRAM_ALLOWED_USERS n'est pas défini dans $ENV_FILE"
  exit 1
fi

# ============================================================================
# Vérifications des dépendances
# ============================================================================
echo "[Hermes] Vérification des dépendances..."

# Vérifier Python
if ! command -v python3 &> /dev/null; then
  echo "[ERROR] Python 3 n'est pas installé ou n'est pas dans le PATH"
  exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "[OK] Python 3 trouvé : $PYTHON_VERSION"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
  echo "[ERROR] Docker n'est pas installé ou n'est pas dans le PATH"
  exit 1
fi
DOCKER_VERSION=$(docker --version)
echo "[OK] $DOCKER_VERSION"

# Vérifier Docker Compose Plugin
if ! docker compose version &> /dev/null 2>&1; then
  echo "[ERROR] Docker Compose Plugin n'est pas disponible"
  echo "Mettez à jour Docker Desktop ou installez docker-compose"
  exit 1
fi
COMPOSE_VERSION=$(docker compose version 2>&1)
echo "[OK] $COMPOSE_VERSION"

# ============================================================================
# Lancer Docker Compose
# ============================================================================
echo ""
echo "[Hermes] Lancement des services Docker Compose..."
echo ""

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "[ERROR] Le fichier $COMPOSE_FILE n'existe pas"
  exit 1
fi

docker compose -f "$COMPOSE_FILE" up -d --build

echo ""
echo "[OK] Services Docker Compose lancés"
echo ""
echo "Accédez aux services sur :"
echo "  - Gateway API       : http://localhost:8642"
echo "  - Dashboard interne : http://localhost:9119"
echo "  - Workspace UI      : http://localhost:3000"
echo ""
echo "Logs en temps réel :"
echo "  docker compose -f $COMPOSE_FILE logs -f"
echo ""