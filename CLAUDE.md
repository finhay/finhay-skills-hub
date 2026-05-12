# CLAUDE.md

Claude Code plugin — agent skills for the Finhay Securities Open API.

## Architecture

- **skills/** — 2 skills (each has `SKILL.md` + endpoint references)
- **finhay.sh** / **finhay.ps1** — Unified CLI for Auth, Doctor, Infer, and Requests
- **.claude-plugin/** — Plugin metadata

## Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| finhay-market | Stock prices, funds, gold, crypto, macro indicators, charts | Prices, rates, market data |
| finhay-portfolio | User profile, balance, portfolio, orders, PnL, user rights, market session, **order execution (place/modify/cancel)** | Profile, trading account, holdings, order history, **placing/modifying/cancelling orders** |

## Prerequisites

- `bash`, `curl`, `openssl`, `jq`, `xxd` (macOS/Linux) or PowerShell 5.1+ (Windows)
- `~/.finhay/credentials/.env` with `FINHAY_API_KEY` and `FINHAY_API_SECRET`

## CLI Commands

All interactions use the unified `finhay.sh` (or `finhay.ps1`) script.

- `auth`: Setup API credentials interactively.
- `doctor`: Check environment and dependency status.
- `infer`: Automatically resolve `USER_ID` and sub-account IDs.
- `request`: Make signed API calls.

```bash
./finhay.sh request GET /market/stock-realtime "symbol=VNM"
```

## Adding a New Endpoint to a Skill

When a new API endpoint is added to the backend (e.g. `vnsc-datafeed-service`), update **all three** of the following files — missing any one will cause the skill to be incomplete:

1. **Create** `skills/<skill>/references/endpoints/<name>.md`
   - OpenAPI spec (path, parameters, response schema with all fields)
   - `### Response Key` section (e.g. `data` or `result`)
   - `### Components` section with all referenced schemas
   - `### Notes` section for edge cases, defaults, enums, error behavior

2. **Update** `skills/<skill>/references/endpoints.md`
   - Add a row to the relevant endpoint table (assign the next available `#` number)
   - Add a row to the "Choosing the Right … Endpoint" guide at the bottom

3. **Update** `skills/<skill>/SKILL.md`
   - Add a row to the `## Endpoints` table with a one-line description and param summary

For **write operations** (POST/PUT/DELETE), additionally:
- Document the body schema in the endpoint detail file's `### Components` section.
- The signing payload for write requests includes a body hash: `{TIMESTAMP}\n{METHOD}\n{PATH}\n{SHA256(body).hex()}`, plus an `X-FH-BODYHASH` header. `./finhay.sh request` handles this when the BODY argument is non-empty.
- For skills that include write operations, also maintain `references/safety.md` (user confirmation protocol) and `references/error-codes.md` (mapping `result[].code` to user-facing messages).

