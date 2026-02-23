import { test, expect } from "@playwright/test";

// Simple test to validate E2E testing setup.
test("shows Ready status: ok after pressing button", async ({ page }) => {
  await page.goto("/");

  await page.getByRole("button", { name: /check api readiness\/db availability/i }).click();

  await expect(page.getByText(/API readiness\/DB up:\s*ready/i)).toBeVisible();
});
