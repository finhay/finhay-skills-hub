# Portfolio Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`).

All endpoints in this skill are **read-only** (`GET`). For order execution (POST place / PUT modify / DELETE cancel), see the `finhay-trading` skill.

## Config Envs

- `USER_ID` — written by `./finhay.sh infer`
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — written by `./finhay.sh infer`

## Path Versions

Versions are fixed per endpoint — do not change them:
- `v2` → portfolio holdings
- `v3` → assets summary
- `v5` → user rights
- (no prefix) → account summary, orders, PnL

---

## Account & Balance

| # | Method | Path | Params | Res key | Purpose | Detail |
|---|--------|------|--------|---------|---------|--------|
| 1 | GET | `/trading/accounts/{subAccountId}/summary` | — | `result` | **Account Summary**: Specific financials for a single stock trading account | [detail](./endpoints/account-summary.md) |
| 2 | GET | `/users/v3/users/{userId}/assets/summary` | `cache-control` | `data` | **User Assets**: Aggregated wealth summary across all Finhay products | [detail](./endpoints/assets.md) |

## Orders (History)

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/sub-accounts/{subAccountId}/orders` | `fromDate`, `toDate` | `result` | [detail](./endpoints/orders.md) |

## Portfolio & PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |
| 2 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## Corporate-Action Rights

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |
