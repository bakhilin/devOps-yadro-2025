"""
Configure service, Consist all meta info.
"""

import os
from src.conf.config import Config
from typing import Optional


class ConfigService(Config):
    def __init__(self, name: str, author: str):
        super().__init__()
        self._name: str = name
        self._author: str = author
        self._api_key: str | None = os.getenv("API_KEY")
        self._version: str = os.getenv("VERSION")

    @property
    def name(self) -> Optional[str]:
        return self._name

    @name.setter
    def name(self, name: str) -> None:
        self._name = name

    @property
    def version(self) -> Optional[str]:
        return self._version

    @version.setter
    def version(self, version: str) -> None:
        self._version = version

    @property
    def author(self) -> Optional[str]:
        return self._author

    @author.setter
    def author(self, author: str) -> None:
        self._author = author
