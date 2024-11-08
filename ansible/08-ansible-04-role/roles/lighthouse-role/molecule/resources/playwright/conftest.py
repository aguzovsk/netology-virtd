import pytest

def pytest_addoption(parser):
  parser.addoption("--url", action="store",
    help="Provide url to LightHouse Nginx port, with Clickhouse HTTP API anchor")
