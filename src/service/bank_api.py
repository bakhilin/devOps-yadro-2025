import json
import requests
import xml.etree.ElementTree as ET
import src.cache.currency_cache as currency_cache
from src.entities.currency import Currency
from fastapi import HTTPException
from src.cache.in_memory_cache import InMemoryCache

class Bank:
    """
    This class provides access to the central bank API of Russia.

    Args:
        cache (Cache): Redis or my In-memory.

    Attributes:
        cache (Cache): Redis or my In-memory.
        _links: urls for fetch data from API Central Bank.
    """

    def __init__(self, cache: currency_cache.Cache):
        self.cache = cache
        self._links = {
            "all_currencies_url": "https://www.cbr.ru/scripts/XML_daily.asp?date_req=",
            "char_code": "https://www.cbr.ru/scripts/XML_daily.asp?date_req=",
        }

    """
    Fetch currency info from api in XML format. 
    """

    @staticmethod
    def fetch_currency_from_api(url):
        try:
            response = requests.get(url)
            response.raise_for_status()
            return response.content
        except requests.exceptions.HTTPError as http_err:
            raise HTTPException(status_code=500, detail=f"http error {http_err}")
        except requests.exceptions.ConnectionError as conn_err:
            raise HTTPException(status_code=500, detail=f"connection error {conn_err}")
        except requests.exceptions.RequestException as req_err:
            raise HTTPException(status_code=500, detail=f"request error {req_err}")

    """
    This method use to get data of all currencies.  
    Doesn't using cache.
    """

    def get_data_from_all_currencies(self, date: str) -> dict:
        try:
            all_currencies_url = self._links["all_currencies_url"] + date
            data_bytes = Bank.fetch_currency_from_api(all_currencies_url)
            data_parsed = Bank.parse_xml_all_currencies(data_bytes, "Valute")
            return data_parsed
        except HTTPException as err:
            raise err
        except Exception as err:
            raise HTTPException(status_code=500, detail=f"unexpected error {err}")

    """
    This method use to get ONE currency by char code. 
    First, check in cache memory. If cached_data exist, return dict with values.
    Second, request to API of Central Bank, and try to find this char code in fetched data.
    Third, if char code was found, save in cache and return dict.
    """

    def get_currency_by_char_code(self, char_code: str, date: str) -> dict:
        if not self.cache.is_active():
            self.cache = InMemoryCache()
            
        cache_key = f"currency:{char_code}:{date}"
        cached_data = self.cache.get(cache_key)

        if cached_data:
            try:
                return json.loads(cached_data[0])
            except json.JSONDecodeError as e:
                print(f"Error parsing cache: {e.msg}")
        try:
            url_for_fetch_currencies_by_one_date = self._links["char_code"] + date
            data = Bank.fetch_currency_from_api(url_for_fetch_currencies_by_one_date)
            root = ET.fromstring(data)
            curr = None
            for val in root.findall("Valute"):
                if val.find("CharCode").text == char_code:
                    curr = Currency(currency=char_code, price=val.find("Value").text)
                    self.cache.set(cache_key, json.dumps(curr.to_dict()))

            self.cache.invalidate_cache_value_by_time()

            return {curr.currency: curr.price}
        except HTTPException as err:
            raise err
        except Exception as err:
            raise err

    """
    Needs to parse all currencies for API: GET /info/currency?date=
    Without currency param. 
    """

    @staticmethod
    def parse_xml_all_currencies(data: bytes, object_name: str) -> dict:
        root = ET.fromstring(data)
        currency_data = []
        for record in root.findall(object_name):
            valuta = {
                record.find("CharCode").text: float(
                    record.find("Value").text.replace(",", ".")
                )
            }
            currency_data.append(valuta)

        merged_dict = {}
        for item in currency_data:
            merged_dict.update(item)

        return merged_dict
