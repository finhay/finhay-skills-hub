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
| finhay-portfolio | User profile, balance, portfolio, orders, PnL, user rights, market session | Profile, trading account, holdings, order history |

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
