import os


class Config:
    def __init__(self):
        self._host: str = os.getenv("HOST", "localhost")
        self._port: int = int(os.getenv("PORT", "8000"))

    @property
    def host(self) -> str:
        return self._host

    @host.setter
    def host(self, host: int) -> None:
        self._host = host

    @property
    def port(self) -> int:
        return self._port

    @port.setter
    def port(self, port: int) -> None:
        self._port = port
