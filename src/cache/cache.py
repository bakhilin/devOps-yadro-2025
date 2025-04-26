"""
Interface for realization cache via Cache I want to realize 2 ways of cache.
But next time maybe more.
"""

from abc import ABC, abstractmethod


class Cache(ABC):
    @abstractmethod
    def set(self, key: str, value: str) -> None:
        pass

    @abstractmethod
    def get(self, key: str) -> str:
        pass

    @abstractmethod
    def is_active(self) -> bool:
        pass

    @abstractmethod
    def invalidate_cache_value_by_time(self):
        pass
