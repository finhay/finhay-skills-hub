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
║  Account:   0881234567 (NORMAL)      ║
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
║  Account:   0881234567 (NORMAL)      ║
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
║  Account:   0881234567 (NORMAL)      ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

## Duplicate Detection

Before placing a new order:

1. Fetch current order book: `GET /trading/v1/accounts/{subAccountId}/order-book`
2. Filter for orders with status in: `RECEIVED`, `SENT`, `WAITING_TO_SEND`, `SENDING`
3. Check if any match **all four**: same `symbol` + same `order_side` + same `order_quantity` + same `limit_price`
4. If match found → show duplicate warning, require `"confirm-duplicate"` instead of `"confirm"`

## Modifiable / Cancellable Statuses

### Can modify

`SENT`, `WAITING_TO_SEND`

### Can cancel

`SENT`, `WAITING_TO_SEND`, `SENDING`

### Cannot modify or cancel

`MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED`, `REJECTED`, `EXPIRED`

Always verify by checking the order detail endpoint before attempting modify/cancel.

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
