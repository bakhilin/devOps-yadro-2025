"""
Head class to decide what cache will be used in application.
"""

from src.cache.in_memory_cache import InMemoryCache
from src.cache.redis_cache import RedisCache
from src.cache.cache import Cache

"""
Keep in CurrencyCache 2 variants of cache realization. 
When object is created, Redis and my In-memory cache realization created both.
"""


class CurrencyCache:
    def __init__(self):
        self.redis_cache = RedisCache()
        self.in_memory_cache = InMemoryCache()

    """
    If redis service in operation system available, 
    must be redis used, other way - just my in memory cache via dict.
    """

    def get_cache(self) -> Cache:
        if self.redis_cache.is_active():
            return self.redis_cache
        else:
            return self.in_memory_cache
