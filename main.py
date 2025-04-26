"""
Initialize client-server app.
1. Configure project by class Config - all settings in this object: port, host, other info.
2. Choose algorithm of cache repression. In my case: LRU - in memory realization, Redis - if online.
3. Init application controller-service.
4. Running app.
"""

import src.conf.config_service as config
import src.service.routes as routes
import src.cache.currency_cache as cache


if __name__ == "__main__":
    config = config.ConfigService(name="currency", author="n.bakhilin")
    cache = cache.CurrencyCache().get_cache()
    app = routes.ServiceCurrency(config, cache)
    app.run()
