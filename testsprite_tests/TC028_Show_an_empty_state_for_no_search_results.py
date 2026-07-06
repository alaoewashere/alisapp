import asyncio
import re
from playwright import async_api
from playwright.async_api import expect

async def run_test():
    pw = None
    browser = None
    context = None

    try:
        # Start a Playwright session in asynchronous mode
        pw = await async_api.async_playwright().start()

        # Launch a Chromium browser in headless mode with custom arguments
        browser = await pw.chromium.launch(
            headless=True,
            args=[
                "--window-size=1280,720",
                "--disable-dev-shm-usage",
                "--ipc=host",
                "--single-process"
            ],
        )

        # Create a new browser context (like an incognito window)
        context = await browser.new_context()
        # Wider default timeout to match the agent's DOM-stability budget;
        # auto-waiting Playwright APIs (expect, locator.wait_for) inherit this.
        context.set_default_timeout(15000)

        # Open a new page in the browser context
        page = await context.new_page()

        # Interact with the page elements to simulate user flow
        # -> navigate
        await page.goto("http://127.0.0.1:8080")
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=5000)
        except Exception:
            pass
        
        # -> Fill the search field with the rare keyword 'zxqjkl123' and submit the search by clicking the 'بحث' button.
        # ابحث عن سيارات، شقق، إلكترونيات text field
        elem = page.get_by_placeholder('ابحث عن سيارات، شقق، إلكترونيات...', exact=True)
        await elem.wait_for(state="visible", timeout=10000)
        await elem.fill("zxqjkl123")
        
        # -> Fill the search field with the rare keyword 'zxqjkl123' and submit the search by clicking the 'بحث' button.
        # بحث button
        elem = page.locator('[id="flt-semantic-node-40"]')
        await elem.click(timeout=10000)
        
        # -> Click the visible 'فهمت' button in the top banner to dismiss it so the search results area becomes fully visible, then re-check for an empty-results message.
        # فهمت button
        elem = page.locator('[id="flt-semantic-node-112"]')
        await elem.click(timeout=10000)
        
        await page.wait_for_selector('html[data-sello-ready="true"]', timeout=90000)
        await page.mouse.wheel(0, 300)
        
        # --> Assertions to verify final state
        
        # --> Verify an empty search results state is displayed
        await expect(page.locator("xpath=/html/body/flutter-view").nth(0)).to_contain_text("\u0644\u0627 \u062a\u0648\u062c\u062f \u0646\u062a\u0627\u0626\u062c", timeout=30000), "Expected the search results to display the Arabic empty-results message '\u0644\u0627 \u062a\u0648\u062c\u062f \u0646\u062a\u0627\u0626\u062c'."
        await expect(page.locator("xpath=/html/body/flutter-view").nth(0)).to_contain_text("\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0646\u062a\u0627\u0626\u062c", timeout=15000), "Expected the search results to display the Arabic empty-results message '\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0646\u062a\u0627\u0626\u062c'."
        await asyncio.sleep(5)

    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()

asyncio.run(run_test())
    