---
name: finhay-portfolio
description: "User identity, account balances, stock holdings, P&L, order history, and corporate-action rights via Finhay Securities Open API. Read-only — use for net worth queries, purchasing power, trading performance, dividend tracking, and portfolio analysis. For placing/modifying/cancelling orders, use the `finhay-trading` skill instead."
license: MIT
metadata:
  author: Finhay Securities
  version: "3.0.0"
---

# Finhay Portfolio

Read-only trading account data via the Finhay Securities Open API: identity, balances, holdings, order history, P&L, and corporate-action rights.

> **MANDATORY**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify. If IDs are missing, run `./finhay.sh infer`.

> To **place / modify / cancel** orders, use the **`finhay-trading`** skill — order execution is intentionally split out for safety and isolation.

## Usage Examples

```bash
# Global net worth across all asset classes
./finhay.sh request GET "/users/v3/users/$USER_ID/assets/summary"

# Cash and buying power for a specific trading account
./finhay.sh request GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"

# Current stock holdings with realtime P&L
./finhay.sh request GET "/trading/v2/sub-accounts/$SUB_ACCOUNT_NORMAL/portfolio"

# Order history for a date range
./finhay.sh request GET "/trading/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" "fromDate=2026-01-01&toDate=2026-05-28"

# Today's P&L
./finhay.sh request GET "/trading/pnl-today/$USER_ID"
```

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
| `/trading/pnl-today/{userId}` | **Daily P&L**: Profit and loss performance for the current session. | `{userId}` → `$USER_ID` |
| `/trading/v5/account/{subAccountId}/user-rights` | **Corporate-Action Rights**: Dividends, stock rights, AGM, conversion events. | `{subAccountId}` → ask user |

For account balance always use a combination of the `/users/v3/users/{userId}/assets/summary` & `/trading/accounts/{subAccountId}/summary` endpoints, to get the most accurate total assets and NAV.

Please note that the `/users/v3/users/{userId}/assets/summary` endpoint provides an aggregated overview across all Finhay products. **IMPORTANT:** `products.bond` in the response indicates the HayBond product, not traditional bonds — these are different things.

## Sub-account Selection

- **NORMAL** → use `$SUB_ACCOUNT_NORMAL`
- **MARGIN** → use `$SUB_ACCOUNT_MARGIN`

Both are populated by `./finhay.sh infer`. Read endpoints use only the short sub-account ID in the path; the extended IDs (`SUB_ACCOUNT_EXT_*`) are only required for write operations in the `finhay-trading` skill.

---

## Constraints

- **Read-only**: Execute `GET` requests only. For order execution, switch to the `finhay-trading` skill.
- **Privacy**: Mask API keys and sensitive credentials in all output.
- **Credentials**: If `FINHAY_API_KEY` or `FINHAY_API_SECRET` are missing, stop and ask the user to provide them or run `./finhay.sh auth`.
- **Sub-account IDs**: Run `./finhay.sh infer` once to populate `USER_ID`, `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` (plus the `EXT_*` variants used by `finhay-trading`).
- **Sub-account selection**: Always confirm the specific account (Normal/Margin) with the user before querying detail endpoints.
- **Price encoding**: Prices are in VND, no multiplier (e.g. 25,500 VND → `25500`).
