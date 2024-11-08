#!/usr/bin/env python3

from argparse import ArgumentParser
from lxml import html
from pathlib import Path
from requests import Session
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

parser = ArgumentParser(
  prog='LightHouse_test',
  description="Render Lighthouse application with ScrapingHub Splash",
  epilog="Done!"
)

parser.add_argument('splash_ip', help='localhost (127.0.0.0/8) or other IP address where Splash is listenning on (port 8050)')
parser.add_argument('url', help='Provide url to LightHouse Nginx port, with Clickhouse HTTP API anchor')
parsed = parser.parse_args()
# parsed = parser.parse_args(['127.0.50.2', 'http://192.168.62.132:8090/#http://192.168.62.130:8123/?user=lighthouse'])
# parsed = parser.parse_args(['127.0.51.2', 'http://192.168.62.196:8090/#http://192.168.62.194:8123/?user=lighthouse'])

# print(Path('.').resolve())

# Called from playbooks directory
splash_script = Path('../splash/splash-scenario.lua').read_text()
# splash_script = Path('molecule/resources/splash/splash-scenario.lua').read_text()

with Session() as splash_session:
  retry = Retry(
    connect=7,
    backoff_factor=0.5,
    status_forcelist=(104,),
    allowed_methods=frozenset(['POST'])
  )
  adapter = HTTPAdapter(max_retries=retry)
  splash_session.mount('http://', adapter)
  response = splash_session.post(url=f"http://{parsed.splash_ip}:8050/execute", json={
    'lua_source': splash_script,
    'url': parsed.url
  })

tree = html.document_fromstring(html=response.json()['html_markup'])
print(tree.xpath('//div[@role="row"]/div[@col-id="Quantity"]/text()')[0])
