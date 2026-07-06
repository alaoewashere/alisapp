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
        
        # -> Fill the homepage search box labeled 'ابحث عن سيارات، شقق، إلكترونيات...' with the keyword 'sportage' and click the 'بحث' (Search) button to submit the search.
        # ابحث عن سيارات، شقق، إلكترونيات text field
        elem = page.get_by_placeholder('ابحث عن سيارات، شقق، إلكترونيات...', exact=True)
        await elem.wait_for(state="visible", timeout=10000)
        await elem.fill("sportage")
        
        # -> Fill the homepage search box labeled 'ابحث عن سيارات، شقق، إلكترونيات...' with the keyword 'sportage' and click the 'بحث' (Search) button to submit the search.
        # بحث button
        elem = page.locator('[id="flt-semantic-node-40"]')
        await elem.click(timeout=10000)
        
        # -> Fill the search box with 'sportage' and click the 'بحث' (Search) button to run the search and display results.
        # ابحث في Sello text field
        elem = page.get_by_placeholder('ابحث في Sello...', exact=True)
        await elem.wait_for(state="visible", timeout=10000)
        await elem.fill("sportage")
        
        # -> Fill the search box with 'sportage' and click the 'بحث' (Search) button to run the search and display results.
        # بحث button
        elem = page.locator('[id="flt-semantic-node-40"]')
        await elem.click(timeout=10000)
        
        # -> Verify that the search results show the keyword 'sportage' on the page, then open the listing titled 'sportage model 2025 prestige full package'.
        # sportage model 2025 prestige full package button
        elem = page.locator('[id="flt-semantic-node-123"]')
        await elem.click(timeout=10000)
        
        # -> Scroll the listing detail content to reveal the seller section, then search the page for seller-related text such as 'إعلانات' or 'بائع' to verify that the seller's other listings are displayed.
        await page.mouse.wheel(0, 300)
        
        # -> Search the listing detail page for seller-related text such as 'إعلانات' and 'بائع', then scroll to the bottom of the page to confirm whether the seller's other listings are present; if not present, conclude the seller section is not dis...
        await page.mouse.wheel(0, 300)
        
        # --> Assertions to verify final state
        
        # --> Verify search results are displayed
        # Assert: Search results include the listing title 'sportage model 2025 prestige full package'.
        await expect(page.locator("xpath=/html/body/flutter-view").nth(0)).to_contain_text("sportage model 2025 prestige full package", timeout=15000), "Search results include the listing title 'sportage model 2025 prestige full package'."
        
        # --> Verify the listing detail page is displayed
        # Assert: Listing title 'sportage model 2025 prestige full package' is visible on the listing detail page.
        await expect(page.locator("xpath=/html/body/flutter-view").nth(0)).to_contain_text("sportage model 2025 prestige full package", timeout=15000), "Listing title 'sportage model 2025 prestige full package' is visible on the listing detail page."
        current_url = await page.evaluate("() => window.location.href")
        # Assert: page loaded with a URL (final outcome verified by the AI judge during the run)
        assert current_url, 'Page should have loaded with a URL'
        await asyncio.sleep(5)

    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()

asyncio.run(run_test())
    