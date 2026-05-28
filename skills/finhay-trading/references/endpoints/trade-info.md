# Trade Info

## `GET /trading/sub-accounts/{subAccountId}/trade-info`

Check buying power (BUY) or available quantity (SELL) before placing an order.

---

### Params

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `subAccountId` | path | Yes | Sub-account ID |
| `symbol` | query | Yes | Stock symbol (e.g. `HPG`) |
| `side` | query | Yes | `BUY` or `SELL` |
| `quote_price` | query | Yes | Price in VND (e.g. `27000`) |

### Response Key

`result`

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `sub_account_id` | string | Sub-account ID |
| `order_side` | string | `BUY` or `SELL` |
| `symbol` | string | Stock symbol |
| `pp0` | long | Buying power (max amount in VND available to buy) |
| `ppse` | long | Buying power after settlement |
| `max_quantity` | long | Max quantity that can be ordered |
| `available_quantity` | long | Available quantity to sell |
| `pp_rate` | string | Purchase power rate |
| `mr_rate` | long | Margin rate |
| `balance` | long | Account balance |
| `quote_price` | long | The quote price sent in the request |

### Usage for Pre-execution Check

**BUY**: Check `pp0 >= quantity x quote_price`. If not, warn the user about insufficient buying power.

**SELL**: Check `available_quantity >= quantity`. If not, warn the user about insufficient shares.

### Example

```bash
source ~/.finhay/credentials/.env
export AGENT_NAME=claude-code

# Check buying power for BUY 100 HPG @ 27,000
./finhay.sh request GET \
  "/trading/sub-accounts/$SUB_ACCOUNT_NORMAL/trade-info" \
  "symbol=HPG&side=BUY&quote_price=27000"

# Check available shares for SELL 100 HPG @ 27,000
./finhay.sh request GET \
  "/trading/sub-accounts/$SUB_ACCOUNT_NORMAL/trade-info" \
  "symbol=HPG&side=SELL&quote_price=27000"
```

### Notes

- This is a GET endpoint — no body, no body hash signing required.
- Always call this before `place-order` to detect insufficient funds/shares early.
- Result is real-time at the moment of the call; market price may change before the actual order.
