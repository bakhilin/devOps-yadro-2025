"""
Currency - object which we return to the client.
"""

from functools import wraps


class Currency:
    """
    Set up currency and price field: _validate_? be able to check input data.
    """

    def __init__(self, currency: str, price: str):
        self.currency: str = self._validate_currency(currency)
        self.price: float | str = self._validate_price(price)

    """
    Decorator checks every fields on base things like string format and empty.
    """

    @staticmethod
    def validator_fields_currency(validate_func):
        @wraps(validate_func)
        def wrapper(self, value, *args, **kwargs):
            if not isinstance(value, str):
                raise ValueError(
                    f"{validate_func.__name__}: value must be string, your={value}"
                )
            if not value.strip():
                raise ValueError(f"{validate_func.__name__}: value cannot be empty")
            return validate_func(self, value, *args, **kwargs)

        return wrapper

    """
    Check price field, if price is 0, error.
    Parse price string to float, replace ex. 35,78 on 35.78
    """

    @validator_fields_currency
    def _validate_price(self, price: str) -> float:
        if not price:
            raise ValueError("Currency could not be 0")
        parsed_price = float(price.replace(",", "."))
        return parsed_price

    """
    Check currency iso char code in correct case.
    Must be uppercase. Else error.
    """

    @validator_fields_currency
    def _validate_currency(self, currency: str) -> str:
        if currency == currency.lower():
            raise ValueError(f"{currency.__name__}: must be in uppercase")
        return currency

    """
    Convert to dict, on correct format of API.
    """

    def to_dict(self) -> dict:
        return {self.currency: self.price}
