# Ticker Ratios

## `GET /market/tickers/:ticker/ratios`

Historical financial ratio trends (PE, PB, ROE, EPS…) for a ticker, by period.

---

### OpenAPI Spec

```yaml
/market/tickers/{ticker}/ratios:
  get:
    summary: Get financial ratio history for a ticker
    operationId: getTickerRatios
    tags:
      - Tickers
    parameters:
      - name: ticker
        in: path
        required: true
        schema:
          type: string
          example: HPG
      - name: period
        in: query
        required: true
        schema:
          type: string
          enum: [annual, quarterly]
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
                  type: object
                  properties:
                    symbol:
                      type: string
                      example: HPG
                    ratios:
                      type: object
                      description: Time-series of financial ratios
      '400':
        description: period is required
```

### Response Key

`data`

### Notes

- `period` is required. Valid values: `annual`, `quarterly`.
