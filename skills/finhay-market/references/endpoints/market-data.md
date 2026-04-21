# Market Data (Global Indices, Stocks, Commodities, FX)

## `GET /market/financial-data/market`

Retrieve historical time-series for global market instruments: major indices (S&P 500, Dow Jones, Nasdaq, VIX, DXY, KOSPI, Hang Seng, Shanghai, Nikkei…), Big Tech US single stocks (Apple, Microsoft, Alphabet, Amazon, Meta, NVIDIA, Tesla), commodities (Gold, Silver, Copper, Crude Oil, Brent Oil, Natural Gas), and FX pairs (EURUSD, USDJPY, GBPUSD).

---

### OpenAPI Spec

```yaml
/market/financial-data/market:
  get:
    summary: Get historical market data by instrument type
    operationId: getMarketData
    tags:
      - Financial Data
    parameters:
      - name: type
        in: query
        required: true
        description: Instrument type
        schema:
          type: string
          enum:
            - SP500
            - DOW_JONES
            - NASDAQ
            - RUSSELL2000
            - VIX
            - DXY
            - KOSPI
            - HANGSENG
            - SHANGHAI
            - NIKKEI
            - APPLE
            - MICROSOFT
            - ALPHABET
            - AMAZON
            - META
            - NVIDIA
            - TESLA
            - GOLD
            - SILVER
            - COPPER
            - CRUDE_OIL
            - BRENT_OIL
            - NATURAL_GAS
            - EURUSD
            - USDJPY
            - GBPUSD
      - name: limit
        in: query
        required: false
        description: Max number of rows (1–500). Defaults to 50.
        schema:
          type: integer
          minimum: 1
          maximum: 500
          default: 50
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
                    $ref: '#/components/schemas/MarketDataPoint'
      '400':
        description: Invalid `type` or `limit` out of range
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    MarketDataPoint:
      type: object
      properties:
        type:
          type: string
          description: Instrument type (echoes the request)
          example: SP500
        country:
          type: string
          enum: [US, KR, HK, CN, JP, UK]
          description: Country/region code of the instrument
          example: US
        date:
          type: string
          format: date
          description: Observation date in `YYYY-MM-DD` format
          example: "2026-04-15"
        year:
          type: integer
          example: 2026
        month:
          type: integer
          example: 4
        value:
          type: number
          description: Observation value (price/index level/rate). DECIMAL(20,4) precision.
          example: 5234.18
```

### Notes

- `type` is required and must be one of the 26 enum values above. Unknown values return an error.
- `limit` is optional; valid range is 1–500, default 50. Values outside the range return HTTP 400.
- Results are ordered by `date` ASC.
- Cached server-side for 360 seconds per `(type, limit)` key.
- Country mapping examples: US → SP500/DOW_JONES/NASDAQ/RUSSELL2000/VIX/DXY/Big Tech/commodities/FX (USD-denominated); KR → KOSPI; HK → HANGSENG; CN → SHANGHAI; JP → NIKKEI.

### Categorization

| Category | Types |
|----------|-------|
| US indices | `SP500`, `DOW_JONES`, `NASDAQ`, `RUSSELL2000`, `VIX`, `DXY` |
| Asia indices | `KOSPI`, `HANGSENG`, `SHANGHAI`, `NIKKEI` |
| US Big Tech stocks | `APPLE`, `MICROSOFT`, `ALPHABET`, `AMAZON`, `META`, `NVIDIA`, `TESLA` |
| Commodities | `GOLD`, `SILVER`, `COPPER`, `CRUDE_OIL`, `BRENT_OIL`, `NATURAL_GAS` |
| FX pairs | `EURUSD`, `USDJPY`, `GBPUSD` |
