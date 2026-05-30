# Hermes Agent Docker Deployment

Ce dépôt déploie une instance locale de Hermes Agent avec un workspace UI via Docker Compose.

## Objectif

Permet de lancer rapidement :
- un backend `hermes-agent` (gateway + dashboard intégré)
- un frontend `hermes-dashboard` (workspace UI)
- une configuration légère basée sur Docker Compose et `.env`

## Contenu du projet

- `hermes-docker-compose.yml` : services Docker Compose
- `.env` : variables d’environnement à définir avant lancement
- `start.sh` : script d’initialisation du container `hermes-agent`
- `templates/`, `backups/`, `docker-service/` : répertoires montés dans le container

## Services

### hermes-agent

- Image : `nousresearch/hermes-agent:latest`
- Commande : `./start.sh`
- Expose :
  - `8642` : gateway API
  - `9119` : dashboard web intégré
- Monte :
  - données persistantes `./.hermes` → `/opt/data`
  - `start.sh` → `/start.sh`
  - `docker-service/`, `temp  - `docker-service/`, `temp  - `docker-service/`, `temp  - `docker-servi-d  - `docker-service/`, `temp  -das  - `docker-service/`, `temp  - `docker-service/`, `temp  - `docker-service/`, `temp  - `dockere w  - `docrkspa  - `docker-service/`, `temu b  - `docker-service/`, `temp  - `docker-servicet`

## Variab## Variab## Variab## Variab## Variab## Variab#im## Variab## Variab## Variab## Variab## Variab## Variab#im## VALLOW## Varia`
- `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA-B_PORT`- `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA-B_ple - `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA- `HERMES_PA-BAM_ALLOWED_USERS=123456789
HERMES_PASSWORD=...
API_SERVER_KEY=...
HERMES_WORKSPACE_WEB_PORT=3000
COOKIE_SECURE=0
```

## Déma## Déma## Déma## Déma## Déma## Déma#ker-compose.yml up -d --build
```

## Arrêt

```sh
docker compose -f hermes-docker-compose.yml down
```

## Logs

```sh
docker compose -f hermes-docker-compose.yml logs -f hermes-agent
docker compose -f hermes-docker-compose.yml logs -f hermes-dashboard
```

## Particularités

- `start.sh` force le modèle par défaut vers `MiniMax-M2.7`
- Le dashboard interne est démarré avec `--insecure`
- Ce projet utilise ce mode pour contourner l’authentification plugin dashboard en local

## Points de vigilance

- `--insecure` est acceptable en local, mais pas recommandé sur un réseau public
- Si le dashboard ne se connecte pas, vérifier :
  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERVE  - `API_SERse.yml`
- `.env`
- `st- `st- `st- `st- tes/`
- `backups/`
- `docker-service/`
