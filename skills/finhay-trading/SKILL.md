---
name: finhay-trading
description: "Place, modify, and cancel stock orders on the Vietnam stock exchange via Finhay Securities Open API. Gated by a daily OTP 2FA session and a mandatory 6-step safety protocol. Real money operations — use ONLY when the user explicitly wants to execute an order (buy, sell, place, modify, cancel)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
---

# Finhay Trading

Stock order execution via the Finhay Securities Open API. **Real money operations** — every action is irreversible once matched on the exchange.

> **MANDATORY — credentials**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify. If IDs are missing, run `./finhay.sh infer`.

> **MANDATORY — order sub-account**: Order execution **only** uses the sub-account whose `subAccountExt` ends in `.4` (a dedicated account provisioned by Finhay for Open API order routing). After `./finhay.sh infer`, the env vars `SUB_ACCOUNT_ORDER` and `SUB_ACCOUNT_EXT_ORDER` are populated **only when** such an account exists in the user's account list. If either is empty, the user does **not** have an order-execution-capable account — stop immediately and report:
>
> > ❌ **Tài khoản đặt lệnh không tồn tại.** Bạn chưa được cấp sub-account hỗ trợ đặt lệnh (`subAccountExt` kết thúc bằng `.4`). Vui lòng liên hệ Finhay Securities để đăng ký tài khoản đặt lệnh trước khi sử dụng tính năng đặt/sửa/huỷ lệnh.
>
> Do **not** fall back to `$SUB_ACCOUNT_NORMAL` / `$SUB_ACCOUNT_MARGIN` — orders sent on those accounts will be rejected.

> For portfolio queries (balance, holdings, P&L, order history), use the **`finhay-portfolio`** skill. This skill is for **execution only**.

## Usage Examples

```bash
# Verify the order sub-account exists before any action (fail fast)
[ -z "$SUB_ACCOUNT_ORDER" ] && { echo "❌ Tài khoản đặt lệnh không tồn tại (subAccountExt phải kết thúc bằng .4). Liên hệ Finhay Securities để đăng ký." >&2; exit 1; }

# Pre-execution check before placing an order — BUY checks pp0 (VND buying power), SELL checks trade (shares)
./finhay.sh request GET "/trading/v2/accounts/$SUB_ACCOUNT_ORDER/available-trade" "orderSide=BUY&symbol=HPG&quotePrice=27000"

# Place a limit BUY order (see Order Execution section for the 6-step safety protocol)
./finhay.sh request POST "/trading/oa/sub-accounts/$SUB_ACCOUNT_ORDER/orders" '' \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_ORDER"'","side":"BUY","symbol":"HPG","quantity":100,"type":"LIMIT","limit_price":25500,"market_price":null,"stock_type":"STOCK"}'

# Modify an existing order
./finhay.sh request PUT "/trading/oa/sub-accounts/$SUB_ACCOUNT_ORDER/orders/ORDER_ID" '' \
  '{"quantity":200,"price":26000}'

# Cancel an existing order (DELETE with body)
./finhay.sh request DELETE "/trading/oa/sub-accounts/$SUB_ACCOUNT_ORDER/orders/ORDER_ID" '' \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_ORDER"'"}'
```

> The third argument is always the query string (`''` when none). The fourth is the JSON body. Don't swap them.

## CLI Command Reference

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials interactively |
| `doctor` | Verify system dependencies and setup status |
| `infer` | Resolve `USER_ID` and trading sub-account IDs |
| `request` | Execute signed API requests |
| `2fa` | Manage daily OTP session for order execution (see "2FA Session" below) |
| `sync` | Update local skill definitions from source |

### Agent Attribution

> **REQUIRED**: Export `AGENT_NAME` before making any request. Use your tool's canonical lowercase identifier in `kebab-case` (e.g. `claude-code`). Any value is accepted as long as it consistently identifies your tool.

```bash
export AGENT_NAME=claude-code
./finhay.sh request POST "/trading/oa/sub-accounts/$SUB_ACCOUNT_ORDER/orders" '' '...'
```

Sent as `X-FH-OPENAPI-AGENT` and embedded in `User-Agent`.

## Endpoints

| Endpoint | Description | Params |
|----------|-------------|--------|
| `/trading/v2/accounts/{subAccountId}/available-trade` | **Pre-execution Check**: BUY → `pp0` (buying power in VND); SELL → `trade` (shares available). | `orderSide`, `symbol`, `quotePrice` |
| `/trading/v1/accounts/{subAccountId}/order-book` | **Order Book**: List of current day's active orders. Used for the duplicate guard and modify/cancel preflight. | `{subAccountId}` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | **Order Detail**: Granular status for a specific order. Used to verify modifiable/cancellable status. | `{subAccountId}`, `{orderId}` |
| `/trading/market/session` | **Market Session**: Current exchange status (Open/Closed) and available order types for the session. | `exchange` (e.g. HOSE) |
| `POST /trading/oa/sub-accounts/{subAccountId}/orders` | **Place Order**: Submit a new stock order. Body required. | body: `sub_account`, `side`, `symbol`, `quantity`, `type`, `limit_price`, `market_price`, `stock_type` |
| `PUT /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | **Modify Order**: Change quantity/price of a pending order. Body required. | body: `quantity`, `price` |
| `DELETE /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | **Cancel Order**: Cancel a pending order. DELETE with body. | body: `sub_account` |

## Sub-account Selection

Order execution **only** uses the sub-account whose `subAccountExt` ends in `.4`. This is a dedicated account type provisioned by Finhay for Open API order routing — other sub-accounts (NORMAL/MARGIN with `.1`/`.2`/etc) are not accepted by the gateway and orders sent on them will be rejected.

- **Order account** → path uses `$SUB_ACCOUNT_ORDER`, body's `sub_account` field uses `$SUB_ACCOUNT_EXT_ORDER`

Both env vars are populated automatically by `./finhay.sh infer` — but **only when** the user has at least one sub-account whose `sub_account_ext` ends in `.4` in their account list. If not, both vars stay empty and order execution is blocked.

Do **not** ask the user to choose between Normal/Margin/etc — the trading skill does not offer that choice. Orders go through the `.4` account exclusively.

### Precheck — verify the order account exists

Before starting the 6-step Safety Protocol (i.e. before Step 1 — Gather parameters), confirm both env vars:

```bash
if [ -z "$SUB_ACCOUNT_ORDER" ] || [ -z "$SUB_ACCOUNT_EXT_ORDER" ]; then
  echo "❌ Tài khoản đặt lệnh không tồn tại. Bạn chưa được cấp sub-account hỗ trợ đặt lệnh qua OpenAPI (subAccountExt phải kết thúc bằng .4). Vui lòng liên hệ Finhay Securities để đăng ký." >&2
  exit 1
fi
```

If the precheck fails:
1. Report the error to the user in Vietnamese as shown above.
2. **Do not** proceed to gather parameters, do not run available-trade, do not run order-book.
3. Do **not** suggest using `$SUB_ACCOUNT_NORMAL` / `$SUB_ACCOUNT_MARGIN` as a workaround — they will be rejected by the Open API gateway.
4. Suggest the user contact Finhay Securities to provision the `.4` account, then re-run `./finhay.sh infer` once provisioned.

---

## 2FA Session (one OTP per day)

Every **write** call to `/trading/oa/sub-accounts/.../orders` (POST place / PUT modify / DELETE cancel) requires a valid daily 2FA session token sent in the `X-FH-2FA-TOKEN` header. The token is bound to one `api_key` and expires at **23:59:59 +07:00** of the day it was issued.

**How the agent should drive this**: after the user has confirmed an order (Step 4 of the Safety Protocol), the agent calls `./finhay.sh 2fa status` to detect the session state, and only initiates the OTP flow if the session is missing or expired. Full step-by-step is in [Order Execution → Step 5 — 2FA Session preflight](#step-5--2fa-session-preflight).

`./finhay.sh` (and the PowerShell equivalent) also keep a **reactive safety net**: if a write request still receives `403 OTP_SESSION_REQUIRED`/`EXPIRED`/`INVALID`/`REVOKED` (e.g. the local file is in sync but the server revoked the session), the skill catches the response and recovers. The proactive preflight in Step 5 should make this path rare in practice.

> **Interactive terminals only.** Auto-recovery prompts for the OTP through the terminal, so it only works when a real TTY is attached. In an **agent / non-interactive context there is no TTY** — the CLI deliberately does **not** auto-send an OTP (which would burn one of the 5 daily requests and then fail at an unanswerable prompt). Instead it prints the manual Step 5 commands and exits non-zero. **This is exactly why the agent must always run the proactive Step 5 preflight before any write** — never rely on the reactive net to mint a session.

### Manual control

```bash
./finhay.sh 2fa request                          # send OTP to the registered email
./finhay.sh 2fa verify <ticket_id> <6-digit otp> # consume OTP, save session
./finhay.sh 2fa status                           # show current session + expiry
./finhay.sh 2fa revoke                           # invalidate session (server + local)
```

Limits enforced by the auth service:
- Max **5** OTP requests per api_key per day.
- Max **3** wrong verify attempts per ticket — then the ticket locks (request a new one).
- Ticket lives **5 minutes** if not verified.

### Failure modes (4xx error codes worth knowing)

| Code | When |
|---|---|
| `OTP_SESSION_REQUIRED` | First write of the day — run Step 5 to mint a session |
| `OTP_SESSION_EXPIRED` | Midnight rolled past while session cached — run Step 5 again |
| `OTP_SESSION_REVOKED` | Someone called `2fa revoke` — re-verify |
| `OTP_INVALID` | Wrong code; remaining attempts in `message` |
| `OTP_LOCKED` | Ticket consumed all attempts; request a new one |
| `OTP_RATE_LIMIT_EXCEEDED` | Hit 5 OTP requests today; wait until tomorrow |
| `OTP_CONTACT_UNAVAILABLE` | No email registered on the account |

> The session is **per api_key**, not per machine. Using the same key from two terminals is fine — multi-session is allowed.

---

## Order Execution

> **⚠ DANGER — REAL MONEY OPERATIONS.** Placing, modifying, and cancelling stock orders on the Vietnam stock exchange involves real money. Every action is **irreversible once matched**. Follow the Safety Protocol below for **every** write operation — no exceptions.

See [references/safety.md](./references/safety.md) for confirmation dialog templates and recovery procedures, [references/error-codes.md](./references/error-codes.md) for `result[].code` mappings, and [references/enums.md](./references/enums.md) for order type / market price / lot type enums.

### Safety Protocol — 6 steps, always

**Follow ALL 6 steps for every order action. Never skip a step.**

> **Before Step 1**: Run the [order-account precheck](#precheck--verify-the-order-account-exists). If `$SUB_ACCOUNT_ORDER` is empty, abort with the error message above — do **not** proceed to any step below.

#### Step 1 — Gather parameters

Ask the user explicitly for every required field. **Never assume or default** side, symbol, quantity, or price.

| Action | Required from user |
|--------|--------------------|
| Place  | side (BUY/SELL), symbol, quantity, price, type (LIMIT/MARKET) |
| Modify | orderId, new quantity and/or new price |
| Cancel | orderId |

#### Step 2 — Pre-execution checks

Before calling the write API, verify via read endpoints:

- **Place — funds/shares**: `GET /trading/v2/accounts/{subAccountId}/available-trade?orderSide={BUY|SELL}&symbol={symbol}&quotePrice={price}` — **BUY**: `result.pp0` is buying power in **VND** → check `pp0 >= quantity × price`. **SELL**: `result.trade` is the number of **shares** available → check `trade >= quantity`. Pass `quotePrice=0` to evaluate at the current market price.
- **Place — market session**: `GET /trading/market/session?exchange={exchange}` — verify the chosen order type is valid for the **current** session before submitting, to avoid an avoidable exchange rejection. Read `exchange_session` and `available_order_types`:
    - **MARKET orders** (`type=MARKET`, `market_price` ∈ `ATO`/`ATC`/`MP`/`MTL`/…): the chosen type **must** be in `available_order_types`, else the order is rejected (`-100113` / `INVALID_ORDER_TYPE_FOR_THIS_SESSION`). `ATO` is `OPEN`-only; `ATC` is `PRE_CLOSED`-only; `MP`/`MTL` only during continuous matching.
    - **LIMIT (LO) orders**: accepted in most live sessions. If `exchange_session` is `CLOSED`, the order will be rejected (`-300025`) — warn the user and require explicit confirmation before submitting.
    - Determine `{exchange}` (HOSE / HNX / UPCOM / HCX) from the symbol; ask the user if ambiguous (most large-cap tickers are HOSE). The "order types by session" tables in [enums.md](./references/enums.md) are the offline reference.
- **Modify/Cancel**: `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}` — confirm the order exists and that the server flag (`allowamend` for modify, `allowcancel` for cancel) affirmatively permits the action. See [Modifiable / Cancellable status](#modifiable--cancellable-status).

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
║  Account:   120C000008.4 (order)     ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

If the API key starts with `ak_live_`, add a `⚠ PRODUCTION — REAL MONEY` warning line.

#### Step 4 — Wait for explicit confirmation

**Only proceed if the user types `confirm`** (or `confirm-duplicate` when a duplicate has been detected). Do not accept `ok`, `yes`, `sure`, `go`, or any other variation. If the user types anything else, treat as cancellation and ask if they want to retry.

#### Step 5 — 2FA Session preflight

**Only after** the user has confirmed in Step 4, check the local 2FA session state:

```bash
./finhay.sh 2fa status
```

Branch on the output (which encodes the 3 possible scenarios):

| Scenario | `2fa status` output | What to do |
|---|---|---|
| **A. No session file** | `❌ Chưa có 2FA session…` | Run the OTP flow (below) |
| **B. Session valid** | `✅ 2FA session đang hoạt động, hết hạn …` | **Skip OTP** — go straight to Step 6 |
| **C. Session expired** | `⚠ 2FA session đã hết hạn …` | Run the OTP flow (below) |

> The status command compares the file's `expires_at` (e.g. `2026-05-13T23:59:59.000+07:00`) against current time, so you don't have to parse the ISO timestamp yourself.

**OTP flow** (for scenarios A and C only):

1. Request the OTP — it is always delivered to the email registered on the user's account:
   ```bash
   ./finhay.sh 2fa request
   ```
   The response prints a `ticket_id` and `masked_destination` (e.g. `u***@gmail.com`). Show the masked destination to the user so they know where to look.
2. Ask the user for the 6-digit code they received.
3. Verify and save the session:
   ```bash
   ./finhay.sh 2fa verify <ticket_id> <6-digit-otp>
   ```
   On success the JWT session token is written to `~/.finhay/credentials/.2fa-session` (mode `0600`). On failure the error code tells you what to do (see "Failure modes" in the 2FA Session section above).
4. Only after `verify` succeeds, continue to Step 6.

> Do **not** call any write order endpoint before this step completes successfully — the request will be rejected with `OTP_SESSION_REQUIRED`/`EXPIRED`/`INVALID`/`REVOKED` at the gateway.

#### Step 6 — Execute and report

Call `./finhay.sh request`, then display:

- `order_id` and `order_status`
- `rejected_reason` or `code` if present (look up in [error-codes.md](./references/error-codes.md))
- Full result summary in readable format

If the API call fails or times out, **immediately** check the order book (GET) to determine whether the order was actually placed. See [safety.md → Recovery from Failures](./references/safety.md#recovery-from-failures).

### Duplicate Guard

Before placing a new order, fetch the current order book and filter for `status` in `RECEIVED`, `SENT`, `WAITING_TO_SEND`, `SENDING`. If any pending order matches **all four** of: same `symbol` + `side` + `qtty` + `price`, warn the user and require `confirm-duplicate` instead of `confirm`.

> Match against the **order-book** schema (`OrderBookEntry`) field names — `side`, `qtty`, `price` — **not** the place-order request fields (`order_side`, `order_quantity`, `limit_price`). They name the same concepts but the keys differ; using the request names finds nothing and the guard silently passes a duplicate.

### Modifiable / Cancellable status

**Authoritative gate — trust the server flags.** Each `OrderBookEntry` carries `allowamend` and `allowcancel` (string flags set by the core). Use these as the source of truth: modify only when `allowamend` affirmatively permits it, cancel only when `allowcancel` does. They are strings — the truthy value is commonly `"Y"`/`"1"`/`true`; confirm from a live response.

The status table below is a **secondary** cross-check (and for explaining *why* to the user). Never rely on it alone — the exchange can gate an order independent of its display status.

| Action | Typically allowed statuses |
|--------|----------------------------|
| Modify | `SENT`, `WAITING_TO_SEND` |
| Cancel | `SENT`, `WAITING_TO_SEND`, `SENDING` |
| Neither | `MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED`, `REJECTED`, `EXPIRED` |

---

## Constraints

- **Privacy**: Mask API keys and sensitive credentials in all output.
- **Credentials**: If `FINHAY_API_KEY` or `FINHAY_API_SECRET` are missing, stop and ask the user to provide them or run `./finhay.sh auth`.
- **Sub-account IDs**: Run `./finhay.sh infer` once to populate `USER_ID` and `SUB_ACCOUNT_ORDER` / `SUB_ACCOUNT_EXT_ORDER`. The user must have at least one sub-account whose `sub_account_ext` ends in `.4` — if not, these vars stay empty and order execution is blocked (see Precheck above).
- **Sub-account selection**: This skill **only** uses the `.4` account exposed via `$SUB_ACCOUNT_ORDER`. Do not ask the user to choose between Normal/Margin/etc — orders must go through the `.4` account exclusively.
- **Write operations**: Require both (a) a valid daily 2FA session (see "2FA Session" above) and (b) explicit user `confirm` (or `confirm-duplicate`) via the 6-step safety protocol. Never batch multiple orders — complete the full cycle per order.
- **Price encoding**: Prices are in VND, no multiplier (e.g. 25,500 VND → `25500`).
- **Channel**: Default to `ONLINE` unless the user specifies otherwise.
- **Production keys**: If the API key starts with `ak_live_`, add a `⚠ PRODUCTION` warning to every confirmation.
- **One order per confirmation cycle**: never batch multiple orders. Complete the full 6-step protocol for each.
