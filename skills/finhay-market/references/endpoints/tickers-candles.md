# Ticker Candles

## `GET /market/tickers/:ticker/candles`

OHLCV candle data for a stock symbol.

---

### OpenAPI Spec

```yaml
/market/tickers/{ticker}/candles:
  get:
    summary: Get OHLCV candle data for a ticker
    operationId: getTickerCandles
    tags:
      - Tickers
    parameters:
      - name: ticker
        in: path
        required: true
        schema:
          type: string
          example: VNM
      - name: resolution
        in: query
        required: false
        schema:
          type: string
          enum: ["1D", "1H", "4H", "30", "15", "5"]
          default: "1D"
        description: Candle resolution
      - name: from
        in: query
        required: true
        schema:
          type: integer
          example: 1609459200
        description: Start time as Unix timestamp in **seconds**
      - name: to
        in: query
        required: true
        schema:
          type: integer
          example: 1704067200
        description: End time as Unix timestamp in **seconds**
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
                  $ref: '#/components/schemas/CandleChart'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    CandleChart:
      type: object
      description: Columnar arrays — each index corresponds to one candle
      properties:
        symbol:
          type: string
          example: VNM
        resolution:
          type: string
          example: "1D"
        time:
          type: array
          items:
            type: integer
          description: Unix timestamps in seconds (ascending)
        open:
          type: array
          items:
            type: number
        close:
          type: array
          items:
            type: number
        high:
          type: array
          items:
            type: number
        low:
          type: array
          items:
            type: number
        volume:
          type: array
          items:
            type: number
```

### Notes

- `from` and `to` must be Unix timestamps in **seconds**, not milliseconds.
- The response uses parallel arrays (columnar format), not an array of objects.
- Resolution `"1D"` = daily; `"1H"`, `"4H"` = intraday hours; `"30"`, `"15"`, `"5"` = minutes.
- Default resolution is `"1D"` if omitted.
- User tier affects data availability: `FREE` tier may receive limited history; `PREMIUM` tier receives full history. Tier is inferred from the `x-userinfo` header; external API callers default to `PREMIUM`.
- If no data is found for the range, all arrays are empty.
