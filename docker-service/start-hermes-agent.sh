#!/bin/sh
set -e

# echo "[Hermes] Initialisation..."

# # Affichage debug
# echo "MODEL_PROVIDER=${HERMES_MODEL_PROVIDER}"
# echo "MODEL=MiniMax-M2.7"
# echo "MINIMAX_BASE_URL=${MINIMAX_BASE_URL}"

# # Configuration LLM
# hermes config set model.provider "${HERMES_MODEL_PROVIDER}" || true
# hermes config set model.default "anthropic/claude-opus-4.6"
# hermes config set model.default "MiniMax-M2.7" || true

# # Configuration endpoint (MiniMax)
# [ -n "${MINIMAX_API_KEY}" ] && \
#   hermes config set MINIMAX_API_KEY "${MINIMAX_API_KEY}" || true

# # Telegram
# [ -n "${TELEGRAM_BOT_TOKEN}" ] && \
#   hermes config set TELEGRAM_BOT_TOKEN "${TELEGRAM_BOT_TOKEN}" || true

# [ -n "${TELEGRAM_ALLOWED_USERS}" ] && \
#   hermes config set TELEGRAM_ALLOWED_USERS "${TELEGRAM_ALLOWED_USERS}" || true

echo "[Hermes] Démarrage gateway..."

# hermes dashboard --no-open --tui --insecure --host 0.0.0.0 --port 9119 &
gateway run