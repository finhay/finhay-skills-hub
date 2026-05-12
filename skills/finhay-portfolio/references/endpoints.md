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
- `oa` (no version number) → order execution (place/modify/cancel)
- (no prefix) → account summary, orders, PnL, market session, trade-info

## Signing for Write Operations

POST/PUT/DELETE requests use a **different signing payload** than GET — the body hash is included:

```
{TIMESTAMP}\n{METHOD}\n{PATH}\n{BODY_HASH}
```

Where `BODY_HASH = SHA256(request_body_json).hex()`. An additional header `X-FH-BODYHASH` is sent with the same hex value.

`./finhay.sh request METHOD PATH QUERY BODY` (and the PowerShell equivalent) handle this automatically — when `BODY` is non-empty, the script computes the body hash, signs the extended payload, and adds the `X-FH-BODYHASH` header.

> Note: write payloads omit the trailing `\n` that GET payloads include. The script handles this difference.

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

## Trade Info (Pre-execution Check)

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 10 | GET | `/trading/sub-accounts/{subAccountId}/trade-info` | `symbol`, `side`, `quote_price` | `result` | [detail](./endpoints/trade-info.md) |

---

## Order Execution (Write)

All three endpoints return data in the `result` key as an array of order results. See [safety.md](./safety.md) for the 5-step protocol and [error-codes.md](./error-codes.md) for `result[].code` mappings.

### Place Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 11 | POST | `/trading/oa/sub-accounts/{subAccountId}/orders` | `sub_account`, `side`, `symbol`, `quantity`, `type`, `limit_price`, `market_price`, `stock_type` | `result` | [detail](./endpoints/place-order.md) |

### Modify Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 12 | PUT | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | `quantity`, `price` | `result` | [detail](./endpoints/modify-order.md) |

### Cancel Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 13 | DELETE | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | `sub_account` | `result` | [detail](./endpoints/cancel-order.md) |
