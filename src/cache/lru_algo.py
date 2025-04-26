"""
Algorithm repression in resident part of memory.
LRU - delete value which used long time ago.
"""

import time
from collections import OrderedDict


class LRUCache:
    """
    Constructor init OrderedDict and cap = capacity. It's parameter to define
    how many values will be loaded in memory, default = 10.
    """

    def __init__(self, ttl: int, cap: int = 10):
        self.cache = OrderedDict()  # remember insertion order. important for LRU
        self.capacity = cap
        self.ttl = ttl

    """
    Check key if exist in cache. If key exist's 
    return value and move to end of queue else nothing.
    """

    def get(self, key: str) -> str | None:
        if key not in self.cache:
            return None

        self.cache.move_to_end(key)
        return self.cache.get(key)

    """
    Set up value by key, if key already in cache, move to end of queue.
    If cache length more than capacity, delete element like FIFO
    """

    def set(self, key: str, value: str) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = (value, time.time())
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)  # True=LIFO False=FIFO
