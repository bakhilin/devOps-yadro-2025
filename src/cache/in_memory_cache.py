"""
In-Memory cache realization. This one of a lot of way to realize
in memory cache. That's mean resident part of memory without swapping in second level of memory
"""

import time
from src.cache.cache import Cache
from src.cache.lru_algo import LRUCache


class InMemoryCache(Cache):
    def __init__(self, ttl: int = 1800, cap: int = 10):
        self.lru_cache = LRUCache(ttl, cap)

    def set(self, key: str, value: str) -> None:
        self.lru_cache.set(key, value)

    def get(self, key: str) -> str:
        return self.lru_cache.get(key)

    """
    This method always available, because in memory dict cache 
    realization ready when python app is running. 
    """

    def is_active(self) -> bool:
        return True  # because resident part of memory always ready (almost)

    """
        Invalidate cache values by the time. Get all keys and check every ttl on expire time
    """

    def invalidate_cache_value_by_time(self) -> None:
        current_time = time.time()
        expired_keys_in_cache = [
            key
            for key, (_, timestamp) in self.lru_cache.cache.items()
            if current_time - timestamp > self.lru_cache.ttl
        ]
        for key in expired_keys_in_cache:
            self.lru_cache.cache.pop(key)
