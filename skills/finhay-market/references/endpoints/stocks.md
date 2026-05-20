# Tickers — VN Stocks

## `GET /market/tickers/:ticker`

Real-time data for a single VN stock. Returns a single object.

## `GET /market/tickers`

Real-time data for multiple VN stocks by symbol list or exchange. Returns an array.

---

### OpenAPI Spec

```yaml
/market/tickers/{ticker}:
  get:
    summary: Get single stock real-time data
    operationId: getStock
    tags:
      - Tickers
    parameters:
      - name: ticker
        in: path
        required: true
        schema:
          type: string
          example: HPG
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
                  $ref: '#/components/schemas/StockRealtime'

/market/tickers:
  get:
    summary: Get multiple stocks by symbols or exchange
    operationId: getStocks
    tags:
      - Tickers
    parameters:
      - name: symbols
        in: query
        required: false
        description: Comma-separated list of tickers. Mutually exclusive with `exchange`.
        schema:
          type: string
          example: HPG,VNM,FPT
      - name: exchange
        in: query
        required: false
        description: Exchange code — returns all stocks in that exchange. Mutually exclusive with `symbols`.
        schema:
          type: string
          enum: [HOSE, HNX, UPCOM]
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
                    $ref: '#/components/schemas/StockRealtime'
      '400':
        description: Neither `symbols` nor `exchange` was provided
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    StockRealtime:
      type: object
      properties:
        symbol:
          type: string
          example: HPG
        name:
          type: string
          example: CTCP Tập đoàn Hòa Phát
        exchange:
          type: string
          enum: [HOSE, HNX, UPCOM]
        stock_type:
          type: string
          enum: [STOCK, ETF, BOND, CW, FUTURES]
        price:
          type: number
          nullable: true
          example: 27500
        close:
          type: number
          nullable: true
          description: Same as `price`
        open:
          type: number
          nullable: true
        high:
          type: number
          nullable: true
        low:
          type: number
          nullable: true
        average:
          type: number
          nullable: true
        ceiling:
          type: number
          nullable: true
        floor:
          type: number
          nullable: true
        reference:
          type: number
          nullable: true
        change:
          type: number
          nullable: true
          description: Price change from reference
        change_percent:
          type: number
          nullable: true
        volume:
          type: number
          nullable: true
        total_volume:
          type: number
          nullable: true
        total_value:
          type: number
          nullable: true
        buy_price_1:
          type: number
          nullable: true
        buy_price_2:
          type: number
          nullable: true
        buy_price_3:
          type: number
          nullable: true
        buy_vol_1:
          type: number
          nullable: true
        buy_vol_2:
          type: number
          nullable: true
        buy_vol_3:
          type: number
          nullable: true
        sell_price_1:
          type: number
          nullable: true
        sell_price_2:
          type: number
          nullable: true
        sell_price_3:
          type: number
          nullable: true
        sell_vol_1:
          type: number
          nullable: true
        sell_vol_2:
          type: number
          nullable: true
        sell_vol_3:
          type: number
          nullable: true
        foreign_bought:
          type: number
          nullable: true
        foreign_sold:
          type: number
          nullable: true
        foreign_remain:
          type: number
          nullable: true
        remain_bid:
          type: number
          nullable: true
        remain_ask:
          type: number
          nullable: true
        pe:
          type: number
          nullable: true
        pb:
          type: number
          nullable: true
        roe:
          type: number
          nullable: true
        market_cap:
          type: number
          nullable: true
        market_cap_category:
          type: string
          nullable: true
          enum: [Micro Cap, Small Cap, Mid Cap, Large Cap]
        influence_score:
          type: number
          nullable: true
        has_newest_news:
          type: boolean
        stock_summary:
          type: string
          nullable: true
        created_at:
          type: number
          description: Unix timestamp
```

### Notes

- `/market/tickers` requires exactly one of `symbols` or `exchange`; returns `400` if neither is provided.
- `close` equals `price`.
- `market_cap_category` thresholds (VND): Micro <100B, Small <1T, Mid <10T, Large ≥10T.
- `stock_type` for ETF symbols is always `ETF` regardless of DB value.
