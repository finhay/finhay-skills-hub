# Trading Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`).

## Config Envs

- `USER_ID` — written by `./finhay.sh infer`
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — written by `./finhay.sh infer`

## Path Versions

Versions are fixed per endpoint — do not change them:
- `v1` → order book
- `v2` → portfolio
- `v3` → assets summary
- `v5` → user rights
- (no prefix) → account summary, orders, PnL, market session

---

## Account & Balance

| # | Method | Path | Params | Res key | Purpose | Detail |
|---|--------|------|--------|---------|---------|--------|
| 1 | GET | `/trading/accounts/{subAccountId}/summary` | — | `result` | **Account Summary**: Specific financials for a single stock trading account | [detail](./endpoints/account-summary.md) |
| 2 | GET | `/users/v3/users/{userId}/assets/summary` | `cache-control` | `data` | **User Assets**: Aggregated wealth summary across all Finhay products | [detail](./endpoints/assets.md) |

## Orders

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 3 | GET | `/trading/sub-accounts/{subAccountId}/orders` | `fromDate`, `toDate` | `result` | [detail](./endpoints/orders.md) |
| 4 | GET | `/trading/v1/accounts/{subAccountId}/order-book` | — | `result` | [detail](./endpoints/order-book.md) |
| 5 | GET | `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | `orderId` (path) | `data` | [detail](./endpoints/order-book-detail.md) |

## Portfolio & PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 6 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |
| 7 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## Others

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 8 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |
| 9 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |
