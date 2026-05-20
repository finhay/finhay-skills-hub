# Tickers — Global Stocks

## `GET /market/tickers/global/:ticker/history`

Daily close price history for Mag7 global stocks (Apple, Microsoft, Alphabet, Amazon, Meta, Nvidia, Tesla). Data sourced from the `market_data` table — daily granularity only, no intraday.

---

### OpenAPI Spec

```yaml
/market/tickers/global/{ticker}/history:
  get:
    summary: Get daily price history for a Mag7 global stock
    operationId: getGlobalStockHistory
    tags:
      - Tickers
    parameters:
      - name: ticker
        in: path
        required: true
        schema:
          type: string
          enum:
            - apple
            - microsoft
            - alphabet
            - amazon
            - meta
            - nvidia
            - tesla
        description: Company name in lowercase
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
                  $ref: '#/components/schemas/GlobalStockHistory'
      '400':
        description: Invalid ticker or limit
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalStockHistory:
      type: object
      properties:
        ticker:
          type: string
          example: APPLE
        currency:
          type: string
          example: USD
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
                example: 213.55
```

### Notes

- Valid `:ticker` values (case-insensitive): `apple`, `microsoft`, `alphabet`, `amazon`, `meta`, `nvidia`, `tesla`. Returns `400` for any other value.
- Results are ordered ascending by date (oldest first).
- `currency` is always `USD`.
- For VN stock OHLCV data use `GET /market/tickers/:ticker/candles` instead.
