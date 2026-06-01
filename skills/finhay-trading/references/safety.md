# Safety Protocol — Detailed Reference

This document expands on the Safety Protocol in SKILL.md. Every order operation — **place, modify, AND cancel** — must follow all 6 steps, including the 2FA preflight in Step 5.

> **2FA is required for all three write actions** (`POST` place, `PUT` modify, `DELETE` cancel). The gateway rejects the request with `OTP_SESSION_REQUIRED` / `EXPIRED` / `INVALID` / `REVOKED` if there is no valid `X-FH-2FA-TOKEN` on the request. Don't skip Step 5 just because the action is a modify/cancel.

## Confirmation Dialog Examples

### Place Order

```
╔══════════════════════════════════════╗
║        ORDER CONFIRMATION            ║
╠══════════════════════════════════════╣
║  Action:    PLACE                    ║
║  Side:      BUY                      ║
║  Symbol:    HPG                      ║
║  Quantity:  100                      ║
║  Price:     25,500 VND               ║
║  Est. cost: 2,550,000 VND            ║
║  Type:      LIMIT                    ║
║  Account:   120C000008.4 (order)     ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

### Modify Order

```
╔══════════════════════════════════════╗
║       MODIFY ORDER CONFIRMATION      ║
╠══════════════════════════════════════╣
║  Order ID:  ORD20240101001           ║
║  Symbol:    HPG (BUY)                ║
║  Current:   100 shares @ 25,500      ║
║  New:       200 shares @ 26,000      ║
║  Account:   120C000008.4 (order)     ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

### Cancel Order

```
╔══════════════════════════════════════╗
║       CANCEL ORDER CONFIRMATION      ║
╠══════════════════════════════════════╣
║  Order ID:  ORD20240101001           ║
║  Symbol:    HPG (BUY)                ║
║  Quantity:  100 shares @ 25,500      ║
║  Status:    SENT                     ║
║  Account:   120C000008.4 (order)     ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

## Duplicate Detection

Before placing a new order:

1. Fetch current order book: `GET /trading/v1/accounts/{subAccountId}/order-book`
2. Filter for orders whose `status` is in: `RECEIVED`, `SENT`, `WAITING_TO_SEND`, `SENDING`
3. Check if any match **all four**: same `symbol` + same `side` + same `qtty` + same `price`
4. If match found → show duplicate warning, require `"confirm-duplicate"` instead of `"confirm"`

> Match against the **order-book** field names (`side`, `qtty`, `price` from the `OrderBookEntry` schema), **not** the place-order request fields (`order_side`, `order_quantity`, `limit_price`). Same concepts, different keys — using the request names matches nothing and lets a duplicate through.

## Market Session Pre-check

Before submitting a **place** order, confirm the order type is valid for the current session — this catches the most common avoidable rejection (`-100113` / `INVALID_ORDER_TYPE_FOR_THIS_SESSION`, or `-300025` outside trading hours).

1. Determine the symbol's exchange — `HOSE`, `HNX`, `UPCOM`, or `HCX` (ask the user if ambiguous; most large-cap tickers are HOSE).
2. Fetch the session: `GET /trading/market/session?exchange={exchange}`.
3. Check `exchange_session` and `available_order_types`:
   - **MARKET types** (`ATO`, `ATC`, `MP`, `MTL`, `MAK`, `MOK`, `PLO`, …) must appear in `available_order_types`. `ATO` → `OPEN` only; `ATC` → `PRE_CLOSED` only; `PLO` → HNX `POST_SESSION` only.
   - **LIMIT (LO)** is accepted in most live sessions; if `exchange_session` is `CLOSED`, warn that the order will be rejected.
4. If the chosen type isn't available for the current session → warn the user and do **not** submit unless they explicitly confirm.

The full session → order-type matrix is in [enums.md](./enums.md).

## Modifiable / Cancellable Statuses

**Authoritative gate: the server flags `allowamend` / `allowcancel`.** Every `OrderBookEntry` carries these string flags, set by the core. Treat them as the source of truth — modify only when `allowamend` affirmatively permits it, cancel only when `allowcancel` does (the truthy value is commonly `"Y"`/`"1"`/`true`; confirm from a live response).

The status lists below are a **secondary** cross-check and for explaining the reason to the user. Do not rely on them alone — the exchange can gate an order independent of its display status.

### Typically can modify

`SENT`, `WAITING_TO_SEND`

### Typically can cancel

`SENT`, `WAITING_TO_SEND`, `SENDING`

### Cannot modify or cancel

`MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED`, `REJECTED`, `EXPIRED`

Always verify by checking the order detail endpoint — and its `allowamend`/`allowcancel` flags — before attempting modify/cancel.

## Recovery from Failures

### Timeout or network error during order placement

1. **Do not retry immediately.**
2. Check the order book: `GET /trading/v1/accounts/{subAccountId}/order-book`
3. Search for a recent order matching the attempted symbol + side + quantity + price.
4. If found → the order was placed successfully. Report it to the user.
5. If not found → the order was not placed. Ask the user if they want to retry.

### Timeout during modify/cancel

1. Check the order detail: `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`
2. If the order status changed → the operation succeeded.
3. If unchanged → the operation may have failed. Ask the user if they want to retry.

## Production vs Test Keys

| Key prefix | Environment | Extra warnings |
|------------|-------------|----------------|
| `ak_test_*` | Test/sandbox | None |
| `ak_live_*` | Production | Add `⚠ PRODUCTION — REAL MONEY` to every confirmation |
