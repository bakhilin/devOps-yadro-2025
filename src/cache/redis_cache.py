"""
Redis cache realization. Inheritance of Cache and Config.
"""

import os
import redis
from src.conf.config import Config
from src.cache.cache import Cache

MAX_KEYS = 10  # capacity


class RedisCache(Cache, Config):
    """
    Consist super constructor - Config parent
    and port for connection to redis memory.
    And redis starts by _run_cache().
    """

    def __init__(self, port: int = 6379):
        super().__init__()
        self.port = port
        self.redis_client: redis.Redis = self._run_cache()

    def set(self, key: str, value: str, ttl: int = 1800) -> None:
        self.redis_client.set(key, value)
        self.redis_client.expire(key, ttl)

    def get(self, key: str) -> str:
        return self.redis_client.get(key)

    """
        By method redis_client.ping() we can understand redis server available or not.
        If available - True. Else False.
    """

    def is_active(self) -> bool:
        try:
            self.redis_client.ping()
            return True
        except (redis.ConnectionError, redis.TimeoutError):
            return False

    """
    Configure and run Redis. 
    """

    def _run_cache(self):
        return redis.Redis(
            host=os.getenv("REDIS_HOST", self.host),
            port=os.getenv("REDIS_PORT", self.port),
            decode_responses=True,
            max_connections=2,
        )

    """
    Invalidate cache values by the time. Get all keys and check every ttl on expire time
    """

    def invalidate_cache_value_by_time(self) -> None:
        keys = self.get_all_keys_in_cache()
        for key in keys:
            if self.redis_client.ttl(key) <= 0:
                self.redis_client.delete(key)

    """
    :return info about how many keys now in cache.
    """

    def get_all_keys_in_cache(self):
        return self.redis_client.keys("*")
