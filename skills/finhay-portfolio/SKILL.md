---
name: finhay-portfolio
description: "User identity, account balances, stock holdings, order history, AND order execution (place, modify, cancel stock orders). Use for net worth queries, purchasing power, trading performance, or placing/modifying/cancelling stock orders."
license: MIT
metadata:
  author: Finhay Securities
  version: "2.1.0"
---

# Finhay Portfolio

Trading data and order execution via the Finhay Securities Open API. Read-only queries for account/portfolio/orders, plus write operations to place, modify, and cancel stock orders.

> **MANDATORY**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify. If IDs are missing, run `./finhay.sh infer`.

## Usage Examples

```bash
# Read — global net worth across all asset classes
./finhay.sh request GET "/users/v3/users/$USER_ID/assets/summary"

# Read — cash and buying power for a specific trading account
./finhay.sh request GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"

# Read — pre-execution check before placing an order
./finhay.sh request GET "/trading/sub-accounts/$SUB_ACCOUNT_NORMAL/trade-info" "symbol=HPG&side=BUY&quote_price=27000"

# Write — place a limit BUY order (see Order Execution section for the 5-step safety protocol)
./finhay.sh request POST "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" '' \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_NORMAL"'","side":"BUY","symbol":"HPG","quantity":100,"type":"LIMIT","limit_price":25500,"market_price":null,"stock_type":"STOCK"}'

# Write — modify an existing order
./finhay.sh request PUT "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" '' \
  '{"quantity":200,"price":26000}'

# Write — cancel an existing order (DELETE with body)
./finhay.sh request DELETE "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" '' \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_NORMAL"'"}'
```

> The third argument is always the query string (`''` when none). The fourth is the JSON body. Don't swap them.

## CLI Command Reference

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials interactively |
| `doctor` | Verify system dependencies and setup status |
| `infer` | Resolve `USER_ID` and trading sub-account IDs |
| `request` | Execute signed API requests |
| `sync` | Update local skill definitions from source |

### Agent Attribution

> **REQUIRED**: Export `AGENT_NAME` before making any request. Use your tool's canonical lowercase identifier in `kebab-case` (e.g. `claude-code`). Any value is accepted as long as it consistently identifies your tool.

```bash
export AGENT_NAME=claude-code
./finhay.sh request GET "/users/v3/users/$USER_ID/assets/summary"
```

Sent as `X-FH-OPENAPI-AGENT` and embedded in `User-Agent`.

## Endpoints

| Endpoint | Description | Params |
|----------|-------------|--------|
| `/users/v3/users/{userId}/assets/summary` | **Portfolio Overview**: Aggregated NAV and balances for all investment products. | `{userId}` → `$USER_ID` |
| `/trading/accounts/{subAccountId}/summary` | **Account Detail**: Granular cash, buying power, and debt for a specific sub-account. | `{subAccountId}` → ask user |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | **Stock Holdings**: Real-time quantity, average price, and market value. | `{subAccountId}` → ask user |
| `/trading/sub-accounts/{subAccountId}/orders` | **Order History**: History of buy/sell transactions. | `{subAccountId}`, `fromDate`, `toDate` |
| `/trading/v1/accounts/{subAccountId}/order-book` | **Order Book**: List of current day's active orders. | `{subAccountId}` → ask user |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | **Order Detail**: Granular status and info for a specific order. | `{subAccountId}`, `{orderId}` |
| `/trading/pnl-today/{userId}` | **Daily P&L**: Profit and loss performance for the current session. | `{userId}` → `$USER_ID` |
| `/trading/v5/account/{subAccountId}/user-rights` | **User Rights**: Trading permissions and account restrictions. | `{subAccountId}` → ask user |
| `/trading/market/session` | **Market Session**: Current status of the stock exchange (Open/Closed). | `exchange` (e.g., HOSE) |
| `/trading/sub-accounts/{subAccountId}/trade-info` | **Pre-execution Check**: Buying power (BUY) or available quantity (SELL) before placing an order. | `symbol`, `side`, `quote_price` |
| `POST /trading/oa/sub-accounts/{subAccountId}/orders` | **Place Order**: Submit a new stock order. Body required. | body: `sub_account`, `side`, `symbol`, `quantity`, `type`, `limit_price`, `market_price`, `stock_type` |
| `PUT /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | **Modify Order**: Change quantity/price of a pending order. Body required. | body: `quantity`, `price` |
| `DELETE /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | **Cancel Order**: Cancel a pending order. DELETE with body. | body: `sub_account` |

For account balance always use a combination of the `/users/v3/users/{userId}/assets/summary` & `/trading/accounts/{subAccountId}/summary` endpoints, to get the most accurate total assets and NAV.

Please note that the `/users/v3/users/{userId}/assets/summary` endpoint provides an aggregated overview across all Finhay products. **IMPORTANT:** `products.bond` in the response indicates the HayBond product, not traditional bonds — these are different things.

## Sub-account Selection

- **NORMAL** → path uses `$SUB_ACCOUNT_NORMAL`, body uses `$SUB_ACCOUNT_EXT_NORMAL`
- **MARGIN** → path uses `$SUB_ACCOUNT_MARGIN`, body uses `$SUB_ACCOUNT_EXT_MARGIN`

> Write endpoints need **both**: the path takes the short sub-account ID, the body's `sub_account` field takes the extended ID. Both are populated by `./finhay.sh infer`.

---

## Order Execution

> **⚠ DANGER — REAL MONEY OPERATIONS.** Placing, modifying, and cancelling stock orders on the Vietnam stock exchange involves real money. Every action is **irreversible once matched**. Follow the Safety Protocol below for **every** write operation — no exceptions.

See [references/safety.md](./references/safety.md) for confirmation dialog templates and recovery procedures, [references/error-codes.md](./references/error-codes.md) for `result[].code` mappings, and [references/enums.md](./references/enums.md) for order type / market price / lot type enums.

### Safety Protocol — 5 steps, always

**Follow ALL 5 steps for every order action. Never skip a step.**

#### Step 1 — Gather parameters

Ask the user explicitly for every required field. **Never assume or default** side, symbol, quantity, or price.

| Action | Required from user |
|--------|--------------------|
| Place  | side (BUY/SELL), symbol, quantity, price, type (LIMIT/MARKET) |
| Modify | orderId, new quantity and/or new price |
| Cancel | orderId |

#### Step 2 — Pre-execution checks

Before calling the write API, verify via read endpoints:

- **Place BUY/SELL**: `GET /trading/sub-accounts/{subAccountId}/trade-info?symbol={symbol}&side={BUY|SELL}&quote_price={price}` — for BUY: check `pp0` (buying power) ≥ `quantity × quote_price`. For SELL: check `available_quantity` ≥ `quantity`.
- **Modify/Cancel**: `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}` — confirm the order exists and is in a modifiable / cancellable status.

#### Step 3 — Confirmation display

Present a confirmation block to the user **before** executing (full templates in [safety.md](./references/safety.md)). For example, for placement:

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

If the API key starts with `ak_live_`, add a `⚠ PRODUCTION — REAL MONEY` warning line.

#### Step 4 — Wait for explicit confirmation

**Only proceed if the user types `confirm`** (or `confirm-duplicate` when a duplicate has been detected). Do not accept `ok`, `yes`, `sure`, `go`, or any other variation. If the user types anything else, treat as cancellation and ask if they want to retry.

#### Step 5 — Execute and report

Call `./finhay.sh request`, then display:

- `order_id` and `order_status`
- `rejected_reason` or `code` if present (look up in [error-codes.md](./references/error-codes.md))
- Full result summary in readable format

If the API call fails or times out, **immediately** check the order book (GET) to determine whether the order was actually placed. See [safety.md → Recovery from Failures](./references/safety.md#recovery-from-failures).

### Duplicate Guard

Before placing a new order, fetch the current order book and filter for status in `RECEIVED`, `SENT`, `WAITING_TO_SEND`, `SENDING`. If any pending order matches **all four** of: same `symbol` + `order_side` + `order_quantity` + `limit_price`, warn the user and require `confirm-duplicate` instead of `confirm`.

### Modifiable / Cancellable status

| Action | Allowed statuses |
|--------|------------------|
| Modify | `SENT`, `WAITING_TO_SEND` |
| Cancel | `SENT`, `WAITING_TO_SEND`, `SENDING` |
| Neither | `MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED`, `REJECTED`, `EXPIRED` |

---

## Constraints

- **Privacy**: Mask API keys and sensitive credentials in all output.
- **Credentials**: If `FINHAY_API_KEY` or `FINHAY_API_SECRET` are missing, stop and ask the user to provide them or run `./finhay.sh auth`.
- **Sub-account IDs**: Run `./finhay.sh infer` once to populate `USER_ID`, `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_EXT_NORMAL`, `SUB_ACCOUNT_MARGIN`, `SUB_ACCOUNT_EXT_MARGIN`.
- **Sub-account selection**: Always confirm the specific account (Normal/Margin) with the user before querying detail endpoints or executing orders.
- **Write operations**: Require explicit user `confirm` (or `confirm-duplicate`) via the 5-step safety protocol. Never batch multiple orders — complete the full cycle per order.
- **Price encoding**: Prices are in VND, no multiplier (e.g. 25,500 VND → `25500`).
- **Channel**: Default to `ONLINE` unless the user specifies otherwise.
- **Production keys**: If the API key starts with `ak_live_`, add a `⚠ PRODUCTION` warning to every confirmation.
- **One order per confirmation cycle**: never batch multiple orders. Complete the full 5-step protocol for each.
