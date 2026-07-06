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
        await page.goto("http://localhost:3000")
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=5000)
        except Exception:
            pass
        
        # -> Fill the email field with 'admin@app.com', fill the password field with '123', then click the 'تسجيل الدخول' (Login) button to submit the admin login form.
        # admin@souqiq.com email field
        elem = page.locator('[id="email"]')
        await elem.wait_for(state="visible", timeout=10000)
        await elem.fill("admin@app.com")
        
        # -> Fill the email field with 'admin@app.com', fill the password field with '123', then click the 'تسجيل الدخول' (Login) button to submit the admin login form.
        # password field
        elem = page.locator('[id="password"]')
        await elem.wait_for(state="visible", timeout=10000)
        await elem.fill("123")
        
        # -> Fill the email field with 'admin@app.com', fill the password field with '123', then click the 'تسجيل الدخول' (Login) button to submit the admin login form.
        # تسجيل الدخول button
        elem = page.get_by_role('button', name='تسجيل الدخول', exact=True)
        await elem.click(timeout=10000)
        
        # -> Click the 'البلاغات' (Reports) link in the sidebar to open the reports inbox page so the full list of reports can be verified.
        # البلاغات 1 link
        elem = page.get_by_role('link', name='البلاغات 1', exact=True)
        await elem.click(timeout=10000)
        
        # --> Assertions to verify final state
        
        # --> Verify reports are displayed
        # Assert: The seeded report 'بلاغ تجريبي — محتوى مضلل (TestSprite TC011)' is visible in the reports table.
        await expect(page.locator("xpath=/html/body/div[1]/div/main/div/div[2]/div[2]/div/table/tbody/tr/td[3]").nth(0)).to_have_text("\u0628\u0644\u0627\u063a \u062a\u062c\u0631\u064a\u0628\u064a \u2014 \u0645\u062d\u062a\u0648\u0649 \u0645\u0636\u0644\u0644 (TestSprite TC011)", timeout=15000), "The seeded report '\u0628\u0644\u0627\u063a \u062a\u062c\u0631\u064a\u0628\u064a \u2014 \u0645\u062d\u062a\u0648\u0649 \u0645\u0636\u0644\u0644 (TestSprite TC011)' is visible in the reports table."
        # Assert: The report's status 'قيد الانتظار' (Pending) is displayed in the inbox.
        await expect(page.locator("xpath=/html/body/div[1]/div/main/div/div[2]/div[2]/div/table/tbody/tr/td[6]").nth(0)).to_have_text("\u0642\u064a\u062f \u0627\u0644\u0627\u0646\u062a\u0638\u0627\u0631", timeout=15000), "The report's status '\u0642\u064a\u062f \u0627\u0644\u0627\u0646\u062a\u0638\u0627\u0631' (Pending) is displayed in the inbox."
        
        # --> Verify the inbox page is visible
        # Assert: Inbox page URL includes '/dashboard/reports'.
        await expect(page).to_have_url(re.compile("dashboard/reports"), timeout=15000), "Inbox page URL includes '/dashboard/reports'."
        await page.locator("xpath=/html/body/div[1]/div/main/div/div[2]/div[2]/div/table/thead/tr").nth(0).scroll_into_view_if_needed()
        # Assert: Reports table header is visible on the inbox page.
        await expect(page.locator("xpath=/html/body/div[1]/div/main/div/div[2]/div[2]/div/table/thead/tr").nth(0)).to_be_visible(timeout=15000), "Reports table header is visible on the inbox page."
        await asyncio.sleep(5)

    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()

asyncio.run(run_test())
    