# Cancel Order

## `DELETE /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}`

Cancel an existing order. Note: this is a DELETE request **with a body**.

---

### OpenAPI Spec

```yaml
/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}:
  delete:
    summary: Cancel an existing order
    operationId: cancelOrder
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
        description: Order ID to cancel (from order-book)
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CancelOrderRequest'
    responses:
      '200':
        description: Cancellation result
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

- `{subAccountId}` — use `$SUB_ACCOUNT_NORMAL` or `$SUB_ACCOUNT_MARGIN` from `.env`
- `sub_account` in body — use `$SUB_ACCOUNT_EXT_NORMAL` or `$SUB_ACCOUNT_EXT_MARGIN` from `.env`
- `{orderId}` — must be obtained from order-book query first

### Components

```yaml
components:
  schemas:
    CancelOrderRequest:
      type: object
      required: [sub_account]
      properties:
        sub_account:
          type: string
          description: Extended sub-account ID (use SUB_ACCOUNT_EXT_NORMAL or SUB_ACCOUNT_EXT_MARGIN from .env)
          example: "120C000008.1"
```

### Example

```bash
source ~/.finhay/credentials/.env
export AGENT_NAME=claude-code

./finhay.sh request DELETE \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" \
  '' \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_NORMAL"'"}'
```

### Notes

- **2FA required**: Cancel is one of the three write-order actions gated by the daily 2FA session at the auth service. Every call must include a valid `X-FH-2FA-TOKEN` header — `./finhay.sh` attaches it automatically when a session exists. See [SKILL.md → 2FA Session](../../SKILL.md#2fa-session-one-otp-per-day) for the OTP flow.
- **Pre-check required**: Before cancelling, query the order detail (`GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`) and verify the order is in a cancellable status.
- **Cancellable statuses**: Generally `SENT`, `WAITING_TO_SEND`, `SENDING`. Orders that are `MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED` cannot be cancelled.
- **Partially matched orders**: If partially matched, cancellation applies only to the unmatched portion.
- **DELETE with body**: This endpoint requires a request body despite being a DELETE method. `./finhay.sh request` handles this correctly via `curl -X DELETE -d "$BODY"`.
