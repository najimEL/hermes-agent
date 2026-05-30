"""
Docker Command Service — Minimal API to control docker compose on the host.
Security:
  - Only whitelisted directories can be targeted
  - No shell execution — subprocess.run with arg list
  - .env / secrets NEVER exposed in responses or logs
"""

import subprocess
from pathlib import Path
from typing import Annotated

from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel


SERVICE_PORT = 18765

# Resolve allowed_dirs.txt to the same directory as this script
_BASE_DIR = Path(__file__).parent.resolve()
ALLOWED_DIRS_FILE = _BASE_DIR / "allowed_dirs.txt"


def load_allowed_dirs() -> set[str]:
    if not ALLOWED_DIRS_FILE.exists():
        return set()
    return {
        line.strip()
        for line in ALLOWED_DIRS_FILE.read_text().splitlines()
        if line.strip() and not line.startswith("#")
    }


def validate_dir(dir_path: str) -> Path:
    allowed = load_allowed_dirs()
    target = Path(dir_path).resolve()
    if not any(target.is_relative_to(Path(a).resolve()) for a in allowed):
        raise HTTPException(403, f"Directory '{dir_path}' is not allowed")
    if not target.exists():
        raise HTTPException(404, f"Directory '{dir_path}' does not exist")
    return target


def run_compose(cwd: Path, args: list[str], timeout: int = 120) -> dict:
    cmd = ["docker", "compose", "-f", "hermes-docker-compose.yml", *args]
    try:
        result = subprocess.run(
            cmd, cwd=cwd, capture_output=True, timeout=timeout, text=True
        )
        return {
            "ok": result.returncode == 0,
            "returncode": result.returncode,
            "message": "Succeeded" if result.returncode == 0 else (result.stderr[:500] or "Failed"),
        }
    except subprocess.TimeoutExpired:
        raise HTTPException(504, "Command timed out")
    except FileNotFoundError:
        raise HTTPException(503, "Docker not found")


# ── FastAPI app ────────────────────────────────────────────────────────────

app = FastAPI(title="Docker Command Service")


class DirRequest(BaseModel):
    compose_dir: str


class UpRequest(BaseModel):
    compose_dir: str
    detach: bool = True


class ServiceRequest(BaseModel):
    compose_dir: str
    service: str | None = None


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/compose/ps")
def compose_ps(body: Annotated[DirRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    return run_compose(cwd, ["ps", "--format", "json"])


@app.post("/compose/up")
def compose_up(body: Annotated[UpRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    extra = ["-d"] if body.detach else []
    return run_compose(cwd, ["up", *extra])


@app.post("/compose/down")
def compose_down(body: Annotated[DirRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    return run_compose(cwd, ["down", "--remove-orphans"])


@app.post("/compose/restart")
def compose_restart(body: Annotated[ServiceRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    service = [body.service] if body.service else []
    return run_compose(cwd, ["restart", *service])


@app.post("/compose/stop")
def compose_stop(body: Annotated[ServiceRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    service = [body.service] if body.service else []
    return run_compose(cwd, ["stop", *service])


@app.post("/compose/start")
def compose_start(body: Annotated[ServiceRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    service = [body.service] if body.service else []
    return run_compose(cwd, ["start", *service])


@app.post("/compose/pull")
def compose_pull(body: Annotated[ServiceRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    return run_compose(cwd, ["pull"])


@app.post("/compose/build")
def compose_build(body: Annotated[ServiceRequest, Body()]):
    cwd = validate_dir(body.compose_dir)
    return run_compose(cwd, ["build", "--no-cache"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=SERVICE_PORT, log_level="warning")