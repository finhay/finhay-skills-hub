# Trading Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`).

## Config Envs

- `USER_ID` — written by `./finhay.sh infer`
- `SUB_ACCOUNT_ORDER` — written by `./finhay.sh infer` (used in **path**) — **required**. Auto-populated from the user's sub-account whose `sub_account_ext` ends in `.4`.
- `SUB_ACCOUNT_EXT_ORDER` — written by `./finhay.sh infer` (used in **body** of write requests) — **required**. The `.4` extended ID.

> Order execution **only** accepts the sub-account whose `subAccountExt` ends in `.4`. If `SUB_ACCOUNT_ORDER` is empty after `infer`, the user does not have an order-execution-capable account — see SKILL.md → "Sub-account Selection → Precheck" for the abort flow. Do **not** substitute `SUB_ACCOUNT_NORMAL` / `SUB_ACCOUNT_MARGIN`; the gateway will reject the order.

## Path Versions

Versions are fixed per endpoint — do not change them:
- `v1` → order book (list + detail)
- `v2` → available-trade (buying/selling power)
- `oa` (no version number) → order execution (place / modify / cancel)
- (no prefix) → market-session

## Signing for Write Operations

POST/PUT/DELETE requests use a **different signing payload** than GET — the body hash is included:

```
{TIMESTAMP}\n{METHOD}\n{PATH}\n{BODY_HASH}
```

Where `BODY_HASH = SHA256(request_body_json).hex()`. An additional header `X-FH-BODYHASH` is sent with the same hex value.

`./finhay.sh request METHOD PATH QUERY BODY` (and the PowerShell equivalent) handle this automatically — when `BODY` is non-empty, the script computes the body hash, signs the extended payload, and adds the `X-FH-BODYHASH` header.

> Note: write payloads omit the trailing `\n` that GET payloads include. The script handles this difference.

## 2FA Header

All three write endpoints additionally require `X-FH-2FA-TOKEN`, a daily JWT session token obtained via the OTP flow. The CLI attaches this header automatically when a valid local session exists. If it is missing or expired, the CLI catches the `403 OTP_SESSION_*` response and — **only in an interactive terminal** — runs the OTP flow and retries; in an agent / non-interactive context it prints the manual Step 5 commands and exits non-zero instead of burning an OTP. See `../SKILL.md` → 2FA Session for details.

---

## Pre-execution Check

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/v2/accounts/{subAccountId}/available-trade` | `orderSide`, `symbol`, `quotePrice` | `result` | [detail](./endpoints/available-trade.md) |

## Order Book (current-day)

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/v1/accounts/{subAccountId}/order-book` | — | `result` | [detail](./endpoints/order-book.md) |
| 2 | GET | `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | `orderId` (path) | `data` | [detail](./endpoints/order-book-detail.md) |

## Market Session

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |

---

## Order Execution (Write)

All three endpoints return data in the `result` key as an array of order results. See [safety.md](./safety.md) for the 6-step protocol and [error-codes.md](./error-codes.md) for `result[].code` mappings.

### Place Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 1 | POST | `/trading/oa/sub-accounts/{subAccountId}/orders` | `sub_account`, `side`, `symbol`, `quantity`, `type`, `limit_price`, `market_price`, `stock_type` | `result` | [detail](./endpoints/place-order.md) |

### Modify Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 2 | PUT | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | `quantity`, `price` | `result` | [detail](./endpoints/modify-order.md) |

### Cancel Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 3 | DELETE | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | `sub_account` | `result` | [detail](./endpoints/cancel-order.md) |
