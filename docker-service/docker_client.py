"""
Client for the docker-service REST API.
Usage:
    from docker_client import DockerServiceClient
    client = DockerServiceClient(api_url="http://host.docker.internal:18765")
    client.restart(compose_dir="/opt/data/hermes-workspace", service="hermes-agent")
"""

import requests


class DockerServiceClient:
    def __init__(self, api_url: str = "http://host.docker.internal:18765"):
        self.base = api_url.rstrip("/")

    def _post(self, endpoint: str, **kwargs):
        r = requests.post(f"{self.base}{endpoint}", json=kwargs, timeout=30)
        r.raise_for_status()
        return r.json()

    def health(self):
        return requests.get(f"{self.base}/health").json()

    def ps(self, compose_dir: str):
        return self._post("/compose/ps", compose_dir=compose_dir)

    def up(self, compose_dir: str, detach: bool = True):
        return self._post("/compose/up", compose_dir=compose_dir, detach=detach)

    def down(self, compose_dir: str):
        return self._post("/compose/down", compose_dir=compose_dir)

    def restart(self, compose_dir: str, service: str | None = None):
        return self._post("/compose/restart", compose_dir=compose_dir, service=service)

    def stop(self, compose_dir: str, service: str | None = None):
        return self._post("/compose/stop", compose_dir=compose_dir, service=service)

    def start(self, compose_dir: str, service: str | None = None):
        return self._post("/compose/start", compose_dir=compose_dir, service=service)

    def pull(self, compose_dir: str, service: str | None = None):
        return self._post("/compose/pull", compose_dir=compose_dir, service=service)

    def build(self, compose_dir: str, service: str | None = None):
        return self._post("/compose/build", compose_dir=compose_dir, service=service)


if __name__ == "__main__":
    import sys
    client = DockerServiceClient()
    print(client.health())