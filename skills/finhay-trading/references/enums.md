# Trading Enums

Use these values exactly as documented when building order request bodies, interpreting order responses, or filtering by status.

## OrderStatus

Returned in `order_status` on every order response (place / modify / cancel / order-book).

`WAITING_TO_ACTIVATE` | `WAITING_TO_SEND` | `SENDING` | `SENT` | `FIXING` | `FIXED` | `CANCELLED` | `CANCELLING` | `MATCHED` | `EXPIRED` | `MATCHED_ALL` | `REJECTED` | `COMPLETED` | `FAILED` | `EXPIRED_ACTIVATION_TIME` | `EXPIRED_AUTHORIZATION` | `RECEIVED` | `INTERNAL_SENDING` | `INTERNAL_CANCELLED` | `SENDING_TO_CORE` | `CANCEL_BY_STOCK_EVENT` | `WAIT_FOR_ACCEPTING` | `ACCEPTED` | `ACCEPTING` | `REJECTING`

## OrderSide

`BUY` | `SELL`

## OrderType (response field, post-exchange representation)

`LO` | `MP` | `ATO` | `ATC` | `MAK` | `MOK` | `MTL` | `PLO` | `FOK` | `FAK`

## StockType (request `stock_type`)

`BOND` | `STOCK` | `FUND_CERTIFICATE` | `WARRANT` | `ETF`

## Exchange (market session, available order types)

`HOSE` | `HNX` | `UPCOM` | `HCX`

---

## Order Execution Enums

### Type (place-order request)

`LIMIT` | `MARKET`

- `LIMIT` → set `limit_price` (price in VND), set `market_price` to `null`
- `MARKET` → set `market_price` (e.g. `ATC`, `ATO`, `MP`), set `limit_price` to `null`

### MarketPrice

`MP` | `ATO` | `ATC` | `MAK` | `MOK` | `MTL` | `PLO` | `FOK` | `FAK`

| Value | Name | Description |
|-------|------|-------------|
| `MP` | Market Price | Match at best available price (HOSE only, converted to MTL by ORS) |
| `ATO` | At The Open | Match at opening session |
| `ATC` | At The Close | Match at closing session |
| `MAK` | Make or Kill | Fill partially or cancel entirely (HNX, converted to FAK by ORS) |
| `MOK` | Moment or Kill | Fill completely or cancel entirely (HNX, converted to FOK by ORS) |
| `MTL` | Moment To Limit | Fill at market then convert remainder to limit |
| `PLO` | Post Limit Order | Limit order after ATC session (HNX post-session only) |
| `FOK` | Fill or Kill | Fill completely or cancel entirely (ORS representation of MOK) |
| `FAK` | Fill and Kill | Fill partially, cancel remainder (ORS representation of MAK) |

#### ORS conversion (post-KRX, May 2025)

The system automatically converts order types to ORS standard:
- HOSE `MP` → ORS `MTL`
- HNX `MAK` → ORS `FAK`
- HNX `MOK` → ORS `FOK`

You can send the original type (MP, MAK, MOK) — the backend converts automatically.

#### Order types by exchange

| Exchange | Supported |
|----------|-----------|
| HOSE | LO, MP, ATO, ATC, MTL |
| HNX | LO, MTL, MOK, MAK, PLO, ATC |
| UPCOM | LO only |
| HCX | LO only |

#### Order types by session (HOSE)

| Session | Supported |
|---------|-----------|
| OPEN | LO, MP, ATO, ATC |
| PROGRESS | LO, MP, ATC |
| BREAK | LO, MP, ATC |
| PRE_CLOSED | LO, ATC |
| CA | LO |

#### Order types by session (HNX)

| Session | Supported |
|---------|-----------|
| OPEN / PROGRESS / BREAK | LO, MTL, MOK, MAK, ATC |
| PRE_CLOSED | LO, ATC |
| POST_SESSION | PLO |
| CA | LO |

### Channel

`ONLINE` | `MOBILE_ANDROID` | `MOBILE_IOS` | `INTERNAL`

Default: `ONLINE` for OpenAPI orders.

### LotType

`EVEN` | `ODD`

- `EVEN` — round lot (100 shares minimum on HOSE/HNX)
- `ODD` — odd lot (1-99 shares). Only `LO` order type allowed.

---

## CacheControl (order-book, market-session)

`CACHE` | `NOCACHE`
