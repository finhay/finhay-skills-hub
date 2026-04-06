---
name: finhay-portfolio
description: "Owner identity, account balances, portfolio, orders, and profit/loss. Use when user asks about their account identity, trading account, stock holdings, order history, or today's PnL."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Portfolio

Read-only trading data via the Finhay Securities Open API. All endpoints use signed `GET` requests.

> **MANDATORY**: Before any action, read and complete [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`, `USER_ID`, and the relevant `SUB_ACCOUNT_*` variable. Do not skip or defer.

## Setup

If `USER_ID` or `SUB_ACCOUNT_*` variables are missing, run once:

```bash
./_shared/scripts/infer-sub-account.sh
```

This writes `USER_ID`, `SUB_ACCOUNT_NORMAL`, and/or `SUB_ACCOUNT_MARGIN` to `~/.finhay/credentials/.env`.

## Making a Request

Always use `request.sh`. Resolve all path variables (`{subAccountId}`, `{userId}`) before calling — the signed path must be the final, fully resolved path.

```bash
source ~/.finhay/credentials/.env

./_shared/scripts/request.sh GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"
./_shared/scripts/request.sh GET "/trading/sub-accounts/$SUB_ACCOUNT_MARGIN/orders" "fromDate=2024-01-01&toDate=2024-01-31"
./_shared/scripts/request.sh GET "/trading/v2/sub-accounts/$SUB_ACCOUNT_NORMAL/portfolio"
./_shared/scripts/request.sh GET "/trading/pnl-today/$USER_ID"
./_shared/scripts/request.sh GET "/trading/market/session" "exchange=HOSE"
```

## Sub-account Selection

When `{subAccountId}` is required, ask the user whether to use NORMAL or MARGIN, then substitute the corresponding env variable:
- NORMAL → `$SUB_ACCOUNT_NORMAL`
- MARGIN → `$SUB_ACCOUNT_MARGIN`

## Endpoints

| Endpoint | Path param | Key params | Res key |
|----------|------------|------------|---------|
| `/trading/accounts/{subAccountId}/summary` | ask user | — | `result` |
| `/trading/sub-accounts/{subAccountId}/asset-summary` | ask user | — | `data` |
| `/trading/sub-accounts/{subAccountId}/orders` | ask user | `fromDate`, `toDate` (required) | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book` | ask user | — | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | ask user | `orderId` (path) | `data` |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | ask user | — | `data` |
| `/trading/pnl-today/{userId}` | `$USER_ID` | — | `data` |
| `/trading/v5/account/{subAccountId}/user-rights` | ask user | — | `result` |
| `/trading/market/session` | — | `exchange` | `result` |

Path versions (`v1`, `v2`, `v5`) are fixed. Always use the exact versions listed above.

Details & response schemas: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md).

## Constraints

See [shared constraints](./_shared/constraints.md), plus:

- `fromDate` and `toDate` are required for the orders endpoint. Never omit them.
- Never substitute `{subAccountId}` without first confirming the sub-account type with the user.
