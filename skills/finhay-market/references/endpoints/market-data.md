# Market Data (Indices, Stocks, Commodities, Forex)

## `GET /market/financial-data/market`

Retrieve historical data points for a global market index, big-tech stock, commodity, or forex pair.

---

### OpenAPI Spec

```yaml
/market/financial-data/market:
  get:
    summary: Get global market data by type
    operationId: getMarketData
    tags:
      - Financial Data
    parameters:
      - name: type
        in: query
        required: true
        description: Market data type
        schema:
          type: string
          enum:
            # US Indices
            - SP500
            - DOW_JONES
            - NASDAQ
            - RUSSELL2000
            - VIX
            - DXY
            # Asian Indices
            - KOSPI
            - HANGSENG
            - SHANGHAI
            - NIKKEI
            # Big-tech stocks
            - APPLE
            - MICROSOFT
            - ALPHABET
            - AMAZON
            - META
            - NVIDIA
            - TESLA
            # Commodities
            - GOLD
            - SILVER
            - COPPER
            - CRUDE_OIL
            - BRENT_OIL
            - NATURAL_GAS
            # Forex
            - EURUSD
            - USDJPY
            - GBPUSD
      - name: limit
        in: query
        required: false
        description: Number of data points to return (default 50, max 500)
        schema:
          type: integer
          default: 50
          minimum: 1
          maximum: 500
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
                  type: array
                  items:
                    $ref: '#/components/schemas/MarketData'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    MarketData:
      type: object
      properties:
        type:
          type: string
          example: "SP500"
        country:
          type: string
          enum: [US, KR, HK, CN, JP, UK]
          example: "US"
        date:
          type: string
          description: Date in YYYY-MM-DD format
          example: "2026-04-22"
        year:
          type: integer
          example: 2026
        month:
          type: integer
          example: 4
        value:
          type: number
          example: 5234.18
```

### Notes

- `type` is required. Results are ordered descending by date (most recent first).
- `limit` defaults to 50; maximum is 500.
