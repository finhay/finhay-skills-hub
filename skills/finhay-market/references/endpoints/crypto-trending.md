# Crypto Trending

## `GET /market/crypto/trending`

List of top trending cryptocurrencies with price, market cap, and multi-timeframe change percentages.

---

### OpenAPI Spec

```yaml
/market/crypto/trending:
  get:
    summary: Get top trending cryptocurrencies
    operationId: getCryptoTrending
    tags:
      - Crypto
    parameters: []
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
                    $ref: '#/components/schemas/CryptoCurrency'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    CryptoCurrency:
      type: object
      properties:
        name:
          type: string
          example: Bitcoin
        symbol:
          type: string
          example: BTC
        icon_url:
          type: string
          description: URL to the coin icon image
        price:
          type: number
          example: 103500.5
        formatted_price:
          type: string
          description: Price formatted with VN locale separator
          example: "103.500,5"
        percent_change_1h:
          type: number
          example: 0.12
        percent_change_24h:
          type: number
          example: -1.45
        percent_change_7d:
          type: number
          example: 3.21
        percent_change_30d:
          type: number
          example: 12.5
        market_cap:
          type: number
          example: 2040000000000
        last_30d_chart:
          type: string
          description: Sparkline data for the 30-day chart (provider-specific format)
```

### Notes

- No parameters — returns all available trending coins.
- `formatted_price` uses Vietnamese locale format (dots as thousands separators, comma as decimal).
- `last_30d_chart` format depends on the upstream data provider; treat as an opaque string.
