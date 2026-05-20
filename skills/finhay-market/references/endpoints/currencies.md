# Currencies

## `GET /market/currencies/:pair/history`

Historical exchange rate for a currency (vs VND), grouped by date with rates from multiple banking organizations.

---

### OpenAPI Spec

```yaml
/market/currencies/{pair}/history:
  get:
    summary: Get exchange rate history for a currency
    operationId: getCurrencyHistory
    tags:
      - Currencies
    parameters:
      - name: pair
        in: path
        required: true
        schema:
          type: string
          enum: [USD, CNY, EUR, JPY]
          example: USD
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: ["1M", "1Y", YTD]
          default: "1M"
        description: 1M = last 1 month, 1Y = last 1 year, YTD = year-to-date
      - name: value_type
        in: query
        required: false
        schema:
          type: string
          enum: [NUMBER, PERCENT]
        description: >
          NUMBER (default) = absolute ask rates.
          PERCENT = % change from the first date in the series.
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
                  $ref: '#/components/schemas/ExchangeRateHistory'
      '400':
        description: Invalid pair, period, or value_type
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    ExchangeRateHistory:
      type: object
      properties:
        last_updated:
          type: string
          nullable: true
          description: Last data update timestamp (YYYY-MM-DD HH:mm:ss)
          example: "2026-05-19 08:00:00"
        chart_items:
          type: array
          description: >
            Each element is a date row. Dynamic keys are banking organization names
            (e.g. Vietcombank, BIDV, Techcombank) with ask rate values.
          items:
            type: object
            properties:
              date:
                type: string
                example: "2026-05-01"
            additionalProperties:
              type: number
              description: Ask rate for this organization on this date
```

### Notes

- Valid currencies: `USD`, `CNY`, `EUR`, `JPY`.
- Organization keys in `chart_items` vary by currency — not all banks quote all currencies.
- Missing organization values on a given date are forward-filled from the previous day.
- `value_type=PERCENT`: first date is always `0` for all orgs; subsequent values are % change from that first rate.
