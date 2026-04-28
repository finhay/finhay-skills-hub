# Trading Economics Data

## `GET /market/financial-data/trading-economics`

Retrieve historical economic indicator data by country and category, sourced from Trading Economics.

---

### OpenAPI Spec

```yaml
/market/financial-data/trading-economics:
  get:
    summary: Get Trading Economics indicator data
    operationId: getTradingEconomicsData
    tags:
      - Financial Data
    parameters:
      - name: country
        in: query
        required: true
        description: Country name
        schema:
          type: string
          enum:
            - China
            - Euro Area
            - Japan
            - United States
            - United Kingdom
            - Vietnam
          example: China
      - name: category
        in: query
        required: false
        description: Indicator category filter
        schema:
          type: string
          enum:
            - GDP
            - Labour
            - Prices
            - Money
            - Trade
            - Government
            - Business
            - Consumer
            - Housing
          example: Prices
      - name: year
        in: query
        required: false
        description: Filter by year (2000–2100)
        schema:
          type: integer
          minimum: 2000
          maximum: 2100
          example: 2024
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
                    $ref: '#/components/schemas/TradingEconomicsData'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    TradingEconomicsData:
      type: object
      properties:
        indicator:
          type: string
          description: Indicator name
          example: "Inflation Rate"
        country:
          type: string
          description: Country name
          enum:
            - China
            - Euro Area
            - Japan
            - United States
            - United Kingdom
            - Vietnam
          example: "China"
        category:
          type: string
          description: Indicator category
          enum: [GDP, Labour, Prices, Money, Trade, Government, Business, Consumer, Housing]
          example: "Prices"
        lastValue:
          type: number
          nullable: true
          description: Most recent value
          example: 0.1
        previousValue:
          type: number
          nullable: true
          description: Prior period value
          example: -0.1
        year:
          type: integer
          description: Year of the data point
          example: 2024
        month:
          type: integer
          description: Month of the data point (1–12)
          example: 3
        unit:
          type: string
          description: Unit of measurement
          example: "%"
```

### Notes

- `country` is required. All other params are optional.
- Results are ordered by `year DESC, month DESC`.
- `lastValue` and `previousValue` may be `null` if data is not yet available.
