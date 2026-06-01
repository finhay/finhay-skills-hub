# Modify Order

## `PUT /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}`

Modify the quantity and/or price of an existing order.

---

### OpenAPI Spec

```yaml
/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}:
  put:
    summary: Modify an existing order
    operationId: updateOrder
    tags:
      - Order Execution
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
      - name: orderId
        in: path
        required: true
        description: Order ID to modify (from order-book)
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/UpdateOrderRequest'
    responses:
      '200':
        description: Modification result
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  nullable: true
                message:
                  type: string
                  nullable: true
                result:
                  type: array
                  items:
                    $ref: '#/components/schemas/OrderResponse'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — use `$SUB_ACCOUNT_ORDER` from `.env`. **Only the `.4` order account is accepted.** If empty after `./finhay.sh infer`, abort per SKILL.md → "Sub-account Selection → Precheck".
- `{orderId}` — must be obtained from order-book query first

### Components

```yaml
components:
  schemas:
    UpdateOrderRequest:
      type: object
      properties:
        quantity:
          type: integer
          format: int64
          minimum: 1
          description: New quantity
        price:
          type: integer
          format: int64
          description: "New limit price in VND"
```

### Example

```bash
source ~/.finhay/credentials/.env
export AGENT_NAME=claude-code

./finhay.sh request PUT \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_ORDER/orders/ORDER_ID" \
  '' \
  '{"quantity":200,"price":26000}'
```

### Notes

- **2FA required**: Modify is one of the three write-order actions gated by the daily 2FA session at the auth service. Every call must include a valid `X-FH-2FA-TOKEN` header — `./finhay.sh` attaches it automatically when a session exists. See [SKILL.md → 2FA Session](../../SKILL.md#2fa-session-one-otp-per-day) for the OTP flow.
- **Pre-check required**: Before modifying, query the order detail (`GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`) and verify the server flag `allowamend` affirmatively permits modification.
- **Authoritative gate**: Trust `allowamend` from the order-book entry, not the display status alone. The status list (`SENT`, `WAITING_TO_SEND` typically modifiable; `MATCHED`, `CANCELLED`, `COMPLETED`, `FAILED` not) is only a secondary cross-check.
- **Partially matched orders**: If an order has been partially matched, only the unmatched portion can be modified. The `rejected_reason` will indicate this.
- **Price encoding**: Same as place order — `price` = price in VND. No multiplication needed.
