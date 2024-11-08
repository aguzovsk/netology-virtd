from playwright.sync_api import Page, expect
import pytest


# @pytest.mark.skip_browser("Microsoft Edge")
@pytest.mark.only_browser('chromium')
def test_title(pytestconfig, page: Page):
  url = pytestconfig.getoption('--url')
  page.goto(url)
  assert page.title() == "LightHouse"


def test_content(pytestconfig, page: Page):
  url = pytestconfig.getoption('--url')
  # page.goto("http://192.168.62.132:8090/#http://192.168.62.130:8123/?user=lighthouse")
  page.goto(url)
  page.locator("#host_password").fill("secret")
  page.get_by_role("button", name="Connect").click()
  page.locator("#database").select_option("logs")
  page.get_by_role("link", name="datadog").click()
  result_rows = int(page.inner_text('#content-result-rows'))

  page.locator("select[name=\"field\"]").select_option("procid")
  page.locator("select[name=\"operator\"]").select_option(">=")
  page.get_by_role("spinbutton").fill("0")
  page.get_by_role("button", name="Filter", exact=True).click()
  assert result_rows <= int(page.inner_text('#content-result-rows'))
  expect(page.locator('#content-result-rows')).to_have_text(str(result_rows))

def test_query(pytestconfig, page: Page):
  url = pytestconfig.getoption('--url')
  page.goto(url)
  page.locator("#host_password").fill("secret")
  page.get_by_role("button", name="Connect").click()

  page.get_by_role("link", name="Query").click()
  # page.locator(".ace_content").fill('SELECT COUNT(*) AS Quantity FROM logs.datadog')
  page.locator("textarea.ace_text-input").fill('SELECT COUNT(*) AS Quantity FROM logs.datadog')
  page.get_by_role("button", name="Execute").click()
  quantity = page.inner_text('div[role=row] div[col-id=Quantity].ag-cell-value')
  assert int(quantity) >= 0
