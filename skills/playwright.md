# playwright (MCP)

**Source:** `anthropics/claude-plugins-official/external_plugins/playwright` → `npx @playwright/mcp@latest`  
**Tier:** 2 — install when E2E testing is needed  
**Workflow:** Work (Magento 2 / Hyvä testing), Personal (client site testing)  
**Install:** Via `.mcp.json` in project root

## What it does

Gives Claude Code full browser automation capabilities:
- Navigate URLs, click elements, fill forms
- Take screenshots
- Assert page states
- Run full end-to-end test flows

Useful for:
- Testing Magento 2 checkout flows without manually clicking through
- Verifying Hyvä frontend components render correctly
- Checking bespoke-floor-sanding.ie contact forms work after deploy

## Install

Add to project `.mcp.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Requires Node.js and npx.

## When to install

- At Mullan: when writing tests for Magento 2 checkout, Livewire components, or Stripe payment flows
- Personal: when verifying client site deploys (test contact form, check mobile layout)

## Decision criteria for Mullan

Check if Darren has existing E2E tests first. If there's already a Playwright or Cypress setup, use that pattern. Don't introduce a second testing approach.
