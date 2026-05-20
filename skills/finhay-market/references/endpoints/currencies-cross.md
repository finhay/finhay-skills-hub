# Currencies — Cross Rates

## `GET /market/currencies/cross/:pair/history`

Daily price history for major cross-rate currency pairs (EURUSD, USDJPY, GBPUSD). Data sourced from the `market_data` table — daily granularity only.

---

### OpenAPI Spec

```yaml
/market/currencies/cross/{pair}/history:
  get:
    summary: Get daily price history for a cross-rate currency pair
    operationId: getCrossRateHistory
    tags:
      - Currencies
    parameters:
      - name: pair
        in: path
        required: true
        schema:
          type: string
          enum:
            - eurusd
            - usdjpy
            - gbpusd
        description: Currency pair (lowercase)
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          default: 30
          minimum: 1
          maximum: 500
        description: Number of most recent records to return
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: integer
                  example: 200
                data:
                  $ref: '#/components/schemas/CrossRateHistory'
      '400':
        description: Invalid pair or limit
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    CrossRateHistory:
      type: object
      properties:
        pair:
          type: string
          example: EURUSD
        points:
          type: array
          items:
            type: object
            properties:
              date:
                type: string
                example: "2026-05-19"
              value:
                type: number
                example: 1.0823
```

### Notes

- Valid `:pair` values: `eurusd`, `usdjpy`, `gbpusd`. Returns `400` for any other value.
- Results ordered ascending by date (oldest first).
- For VND exchange rates (USD/VND, EUR/VND…) use `GET /market/currencies/:pair/history` instead — different source and response shape.
