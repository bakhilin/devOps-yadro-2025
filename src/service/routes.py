import uvicorn
from fastapi import FastAPI, APIRouter, Query
from src.conf.config_service import ConfigService
from datetime import datetime
from src.service.bank_api import Bank
from starlette.responses import RedirectResponse
from src.cache.cache import Cache
from fastapi import HTTPException


class ServiceCurrency:
    """
    The main class for working with the currency API.

    Args:
        conf (ConfigService): Service configuration.
        cache (Cache): Cache for storing data.

    Attributes:
        config (ConfigService): Service configuration.
        bank_service (Bank): Service for working with currency data.
        app (FastAPI): FastAPI application.
        router (APIRouter): Router for registering routes.
    """

    def __init__(self, conf: ConfigService, cache: Cache):
        self.config = conf
        self.bank_service = Bank(cache)
        self.app = FastAPI()
        self.router = APIRouter()
        self._register_routes()

    """
    Registers routes for a FastAPI application.
    """

    def _register_routes(self):
        """
        Redirect to /info page.
        """

        @self.app.get("/")
        def redirect_to_info_from_home():
            return RedirectResponse(url="/info")

        """
        Return info about service.
        """

        @self.router.get("/info")
        def get_info():
            return {
                "version": self.config.version,
                "service": self.config.name,
                "author": self.config.author,
            }

        """
        Returns currency data for a specific date.
        """

        @self.router.get("/info/currency")
        def get_currency(
            currency: str = Query(
                None,
                description="The src in the ISO 4217 standard. If the parameter is omitted, "
                "output all available currencies of the Central Bank of the Russian "
                "Federation and their exchange rate to the ruble.",
            ),
            date: str = Query(..., description="Date in YYYY-MM-DD format"),
        ):
            date = datetime.strptime(date, "%Y-%m-%d").strftime("%d-%m-%Y")

            if not currency:
                try:
                    all_currencies = self.bank_service.get_data_from_all_currencies(
                        date
                    )
                    return {"service": self.config.name, "data": all_currencies}
                except HTTPException as err:
                    raise err
                except Exception as err:
                    raise HTTPException(
                        status_code=500, detail=f"unexpected error {err}"
                    )
            else:
                one_currency = self.bank_service.get_currency_by_char_code(
                    char_code=currency, date=date
                )
                return {"service": self.config.name, "data": one_currency}

        self.app.include_router(self.router)

    """
    Launches a FastAPI application on the specified host and port.
    If the port is busy, error handling is not implemented (TODO).
    """

    def run(self):
        try:
            uvicorn.run(self.app, host=self.config.host, port=self.config.port)
        except OSError as e:
            raise e
