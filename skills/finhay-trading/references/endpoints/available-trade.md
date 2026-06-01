# Available Trade (buying / selling power)

## `GET /trading/v2/accounts/{subAccountId}/available-trade`

Check how many **shares** of a symbol the account can buy (or sell) before placing an order. Replaces the deprecated `trade-info` endpoint — note the semantics changed: `pp0` is now a **share count**, not a VND amount.

---

### Params

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `subAccountId` | path | Yes | Sub-account ID (short form — use `$SUB_ACCOUNT_ORDER`, the `.4` order account) |
| `orderSide` | query | Yes | `BUY` or `SELL` |
| `symbol` | query | Yes | Stock symbol (e.g. `HPG`) |
| `quotePrice` | query | Yes | Intended order price in VND, used to compute `pp0`. Pass the LIMIT price for LIMIT orders, or `0` to evaluate at the current market price (e.g. MARKET orders). |

### OpenAPI Spec

```yaml
/trading/v2/accounts/{subAccountId}/available-trade:
  get:
    summary: Get available buying/selling quantity (in shares) for a symbol
    operationId: getAvailableTrade
    tags:
      - Order Execution
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
          example: "0001229509"
      - name: orderSide
        in: query
        required: true
        schema:
          type: string
          enum: [BUY, SELL]
      - name: symbol
        in: query
        required: true
        schema:
          type: string
          example: "HPG"
      - name: quotePrice
        in: query
        required: true
        description: Intended order price in VND; 0 = use current/market price
        schema:
          type: integer
          format: int64
          example: 0
    responses:
      '200':
        description: Available-trade result
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  description: '"0" = success; any other value = error'
                  example: "0"
                message:
                  type: string
                  nullable: true
                popup_message:
                  type: string
                  nullable: true
                title:
                  type: string
                  nullable: true
                result:
                  $ref: '#/components/schemas/AvailableTradeResult'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — use `$SUB_ACCOUNT_ORDER` from `.env` (short ID, populated by `./finhay.sh infer` from the user's `.4` sub-account). **Only the `.4` order account is accepted** — if empty, abort per SKILL.md → "Sub-account Selection → Precheck".

### Components

```yaml
components:
  schemas:
    AvailableTradeResult:
      type: object
      properties:
        pp0:
          type: integer
          format: int64
          description: >
            Maximum number of SHARES of {symbol} the account can trade for the
            given orderSide at quotePrice. Already expressed in shares — compare
            it directly against the requested quantity (do NOT multiply by price).
        ppse:
          type: integer
          format: int64
          description: Max shares after settlement (purchasing power after settlement)
        maxqtty:
          type: integer
          format: int64
          description: Max quantity cap from the broker
        trade:
          type: integer
          format: int64
          description: Tradeable amount
        balance:
          type: integer
          format: int64
          description: Account cash balance (VND)
        cash_pending_send:
          type: integer
          format: int64
          description: Cash pending transfer (VND)
        mortgage:
          type: integer
          format: int64
          description: Mortgage value (VND)
        marginrate:
          type: number
          description: Margin rate
        mrratioloan:
          type: number
          nullable: true
          description: Margin ratio loan
```

### Usage for Pre-execution Check

The key field is **`pp0`** — the maximum number of shares of `{symbol}` the account can trade. It is already in **shares**, so compare it directly against the requested quantity (do NOT multiply by price, unlike the old `trade-info`).

- **BUY**: check `result.pp0 >= quantity`. If `quantity > pp0`, warn the user about insufficient buying power.
- **SELL**: check `result.pp0 >= quantity`. If `quantity > pp0`, warn the user about insufficient available shares.

### Example

```bash
source ~/.finhay/credentials/.env
export AGENT_NAME=claude-code

# Max shares of HPG the account can BUY at a 27,000 VND limit price
./finhay.sh request GET \
  "/trading/v2/accounts/$SUB_ACCOUNT_ORDER/available-trade" \
  "orderSide=BUY&symbol=HPG&quotePrice=27000"

# Max shares of HPG the account can SELL (0 = evaluate at market price)
./finhay.sh request GET \
  "/trading/v2/accounts/$SUB_ACCOUNT_ORDER/available-trade" \
  "orderSide=SELL&symbol=HPG&quotePrice=0"
```

### Notes

- This is a GET endpoint — no body, no body-hash signing required.
- **Sub-account**: Use `$SUB_ACCOUNT_ORDER` only — same constraint as the write endpoints (the precheck must return data for the account that will actually execute the order). Substituting `$SUB_ACCOUNT_NORMAL` / `$SUB_ACCOUNT_MARGIN` would return a different account's data and lead to incorrect Step 2 decisions.
- **`pp0` is a SHARE count**, not VND. Never multiply by `quotePrice`. This is the key difference from the deprecated `trade-info` endpoint (where `pp0` was buying power in VND).
- `error_code` is a **string**; `"0"` means success. Any other value indicates an error — surface `message` / `popup_message` to the user.
- Pass the intended LIMIT price as `quotePrice` for LIMIT orders; pass `0` to evaluate against the current market price.
- Always call this before `place-order` to detect insufficient funds/shares early.
- Result is real-time at the moment of the call; the market price may move before the actual order.
