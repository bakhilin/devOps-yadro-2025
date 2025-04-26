import json
import pytest
import requests_mock
from src.service.bank_api import Bank
from src.cache.currency_cache import CurrencyCache


def extract_urls_from_collection():
    with open("collections/bruno_currency.json", "r") as file:
        collection = json.load(file)
    urls = []
    for item in collection["items"]:
        if "request" in item and "url" in item["request"]:
            urls.append(item["request"]["url"])
    return urls


@pytest.fixture()
def bank():
    cache = CurrencyCache().get_cache()
    return Bank(cache)


def test_fetch_currency_from_api_success(bank: Bank):
    urls = extract_urls_from_collection()
    for url in urls:
        assert bank.fetch_currency_from_api(url) is not None


def test_fetch_currency_from_api_failure(bank):
    with requests_mock.Mocker() as m:
        url = "https://www.cbr.ru/scripts/XML_daily.asp?date_req=20/12/2004"
        m.get(url, status_code=500)
        result = bank.fetch_currency_from_api(url)
        assert result is None


def test_get_currency_by_char_code(bank):
    result = bank.get_currency_by_char_code("USD", "20/05/2023")
    print(result)
    assert result == {"USD": 79.9093}


def test_get_currency_by_char_code_cached(bank):
    cache_key = "currency:USD:20/05/2023"
    bank.cache.set(cache_key, '{"USD": 79.9093}')
    result = bank.get_currency_by_char_code("USD", "20/05/2023")
    assert result == {"USD": 79.9093}
