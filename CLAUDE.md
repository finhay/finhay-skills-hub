# CLAUDE.md

Claude Code plugin — agent skills for the Finhay Securities Open API.

## Architecture

- **skills/** — 7 skills: 3 endpoint-catalog skills (each has `SKILL.md` + endpoint references) + 3 workflow skills (`finhay-portfolio-review`, `finhay-market-briefing`, `finhay-stock-research` — `SKILL.md` + workflow references, no endpoint docs of their own) + 1 meta-skill (`finhay-guardrails` — the shared compliance rulebook G1–G10 all workflows inherit; single Legal-review surface)
- **finhay.sh** / **finhay.ps1** — Unified CLI for Auth, Doctor, Infer, Requests, and 2FA session management
- **.claude-plugin/** — Plugin metadata

## Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| finhay-market | Stock prices, funds, gold, crypto, macro indicators, charts | Prices, rates, market data |
| finhay-portfolio | Read-only: user profile, balances, holdings, order history, PnL, corporate-action rights | Net worth, purchasing power, trading performance, dividend tracking |
| finhay-trading | **Write**: place / modify / cancel stock orders. 2FA-gated, 6-step safety protocol | Order execution only — buy, sell, cancel, modify |
| finhay-portfolio-review | **Workflow** (read-only): portfolio snapshot → top-3 risks with evidence → safe risk-reduction options; compliance guardrails baked in; source of truth for the Remote-MCP `instructions`/prompt renders | "Review my portfolio", "what risks am I holding", "how do I reduce risk" |
| finhay-market-briefing | **Workflow** (read-only): portfolio-tied market briefing — only news/moves/events mapped to held symbols (date + source required) + upcoming watch-items; general-market fallback when account access not granted | "What's affecting my portfolio today", "news about my holdings" |
| finhay-stock-research | **Workflow** (read-only): single-stock research brief — quote + history + fundamentals (every figure carries its reporting period) + news + analyst reports attributed as third-party opinions; never concludes buy/sell | "Analyze FPT", "is HPG any good", "research this stock" |
| finhay-guardrails | **Meta-skill** (policy): shared compliance rulebook G1–G10 inherited by every workflow skill; single Legal-review surface; source of the `COMPLIANCE` instructions render | Applies to all analysis output; not user-invoked |

## Prerequisites

- `bash`, `curl`, `openssl`, `jq`, `xxd` (macOS/Linux) or PowerShell 5.1+ (Windows)
- `~/.finhay/credentials/.env` with `FINHAY_API_KEY` and `FINHAY_API_SECRET`

## CLI Commands

All interactions use the unified `finhay.sh` (or `finhay.ps1`) script.

- `auth`: Setup API credentials interactively.
- `doctor`: Check environment and dependency status.
- `infer`: Automatically resolve `USER_ID` and sub-account IDs.
- `request`: Make signed API calls.
- `2fa`: Manage the daily OTP session that gates `place/modify/cancel` order endpoints (subcommands: `request`, `verify`, `status`, `revoke`).

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

For **write operations** (POST/PUT/DELETE) — currently only in `finhay-trading`:
- Document the body schema in the endpoint detail file's `### Components` section.
- The signing payload for write requests includes a body hash: `{TIMESTAMP}\n{METHOD}\n{PATH}\n{SHA256(body).hex()}`, plus an `X-FH-BODYHASH` header. `./finhay.sh request` handles this when the BODY argument is non-empty.
- All write endpoints additionally require a daily 2FA session (`X-FH-2FA-TOKEN` header) — see `skills/finhay-trading/SKILL.md` → 2FA Session.
- For skills that include write operations, also maintain `references/safety.md` (user confirmation protocol) and `references/error-codes.md` (mapping `result[].code` to user-facing messages).

